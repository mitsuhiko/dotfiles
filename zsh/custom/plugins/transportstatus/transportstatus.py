import os
import re
import sys
import json
import socket
import datetime
import subprocess
from urllib.request import urlopen


_station_re = re.compile(r'(?i)\s+(Hbf|hl\.?\s+n\.?)$')
_pattern_re = re.compile(r':([a-z_+]+)')
socket.setdefaulttimeout(5.0)


def parse_time(ts):
    return datetime.datetime.strptime(ts, '%Y-%m-%dT%H:%M:%S')


def strip_station(station):
    return _station_re.sub('', station)


def get_wifi_info():
    rv = {}
    for line in subprocess.Popen(
        ['/System/Library/PrivateFrameworks/Apple80211.framework/Versions/Current/Resources/airport', '--getinfo'],
        stdout=subprocess.PIPE).communicate()[0].splitlines():
        args = [x.strip().decode('utf-8') for x in line.split(b':')]
        if len(args) == 2:
            rv[args[0]] = args[1]
    return rv


class StatusProperty(object):

    def __init__(self, name, default=None, ty=None):
        self.name = name
        self.default = default
        self.ty = ty

    def __get__(self, obj, type=None):
        if obj is None:
            return self
        status = obj._get_status_dict()
        if status is not None:
            rv = status
            for part in self.name.split('.'):
                if part not in rv:
                    return self.default
                rv = rv[part]
            return (self.ty or (lambda x: x))(rv)
        return self.default


class TransportInfo(object):
    type = 'unknown'
    default_template = ''
    is_available = False
    _cache = None

    def _fetch_status_dict(self):
        return None

    def _get_status_dict(self, refresh=False):
        if self._cache is not None and not refresh:
            return self._cache
        try:
            rv = self._fetch_status_dict()
            if rv is not None:
                self._cache = rv
                return rv
        except Exception:
            pass

    @property
    def is_available(self):
        return self._get_status_dict() is not None

    def get_data(self):
        return {'is_available': False}

    def get_template(self):
        return os.environ.get('%s_TEMPLATE' % self.type.upper()) \
            or self.default_template


class PlaneInfo(TransportInfo):
    type = 'plane'
    default_template = ':orig_airport to :dst_airport'

    dist_to_dst = None
    ground_speed = None
    is_online = False
    flight_number = None
    aircraft_type = None
    aircraft_registration = None
    orig_airport = None
    dst_airport = None
    ground_speed = None
    altitude = None
    dist_to_dst = None
    elapsed_time = None
    eta = None


class TrainInfo(TransportInfo):
    type = 'train'
    default_template = ':train_number'

    train_number = None
    orig_station = None
    dst_station = None
    eta = None


class AustrianPlaneInfo(PlaneInfo):

    def _fetch_status_dict(self):
        rv = urlopen('https://www.myaustrian-flynet.com/fapi/flightData')
        if rv.code == 200:
            return json.load(rv)

    @property
    def eta(self):
        d = (self._get_status_dict() or {}).get('dest')
        if d and 'localTimeAtArrival' in d:
            now = parse_time(d['localTime'])
            landing = parse_time(d['localTimeAtArrival'])
            minutes = (landing - now).total_seconds() // 60
        else:
            dist = self.dist_to_dst
            speed = self.ground_speed
            if dist is not None and speed:
                minutes = dist / (speed * 0.65) * 60
            else:
                return
        return '%02d:%02d' % (
            minutes // 60,
            int(minutes % 60),
        )

    is_online = StatusProperty('internetAvailable', default=False)
    flight_number = StatusProperty('flightNumber')
    aircraft_type = StatusProperty('aircraftType')
    aircraft_registration = StatusProperty('aircraftRegistration')
    orig_airport = StatusProperty('orig.code')
    dst_airport = StatusProperty('dest.code')
    ground_speed = StatusProperty('groundSpeed')
    altitude = StatusProperty('altitude')
    dist_to_dst = StatusProperty('distDest', ty=float)
    elapsed_time = StatusProperty('elapsedFlightTime')


class LufthansaPlaneInfo(PlaneInfo):

    def _fetch_status_dict(self):
        rv = urlopen('http://services.inflightpanasonic.aero/inflight/services/flightdata/v1/flightdata')
        if rv.code == 200:
            return json.load(rv)

    @property
    def is_online(self):
        rv = urlopen('http://services.inflightpanasonic.aero/inflight/services/exconnect/v1/status')
        if rv.code == 200:
            d = json.load(rv)
            return bool(d and d.get('internet_connectivity_status'))
        return False

    @property
    def flight_number(self):
        rv = (self.flight_number_raw or '').strip()
        if rv[:1] == 'D':
            rv = rv[1:]
        return rv or None

    @property
    def eta(self):
        d = self._get_status_dict()
        if not d:
            return None
        ttl = int(d.get('td_id_fltdata_time_to_destination'))
        return '%02d:%02d' % (
            int(ttl / 60.0),
            int(ttl % 60.0),
        )

    flight_number_raw = StatusProperty('td_id_fltdata_flight_number')
    aircraft_registration = StatusProperty('td_id_airframe_tail_number')
    orig_airport = StatusProperty('td_id_fltdata_departure_baggage_id')
    dst_airport = StatusProperty('td_id_fltdata_destination_baggage_id')
    ground_speed = StatusProperty('td_id_fltdata_ground_speed', ty=int)
    altitude = StatusProperty('td_id_fltdata_altitude', ty=int)
    dist_to_dst = StatusProperty('distDest', ty=float)


class AirCanadaPlaneInfo(PlaneInfo):

    def _fetch_status_dict(self):
        rv = urlopen('https://wifi.inflightinternet.com/abp/v2/statusTray?fig2=true')
        if rv.code == 200:
            return json.load(rv).get('Response') or {}

    @property
    def is_online(self):
        d = self._get_status_dict()
        if not d:
            return False
        return d.get('systemInfo', {}).get('linkState') == 'UP'

    @property
    def flight_number(self):
        return self.flight_number_raw

    @property
    def eta(self):
        d = self._get_status_dict()
        if not d:
            return None
        ttl = int((d.get('systemInfo') or {}).get('timeToLand') or 0)
        return '%02d:%02d' % (
            int(ttl / 60.0),
            int(ttl % 60.0),
        )

    flight_number_raw = StatusProperty('flightInfo.flightNumberInfo')
    aircraft_registration = StatusProperty('flightInfoFIG2.aircraft.registration_number')
    orig_airport = StatusProperty('flightInfo.departureAirportCodeIata')
    dst_airport = StatusProperty('flightInfo.destinationAirportCodeIata')
    ground_speed = StatusProperty('flightInfoFIG2.flight.gps.estimated.speed', ty=int)
    altitude = StatusProperty('flightInfo.altitude', ty=int)
    dist_to_dst = StatusProperty('flightInfoFIG2.flight.gps.calculations.distance_to_arrival', ty=float)


class AeroflotPlaneInfo(PlaneInfo):

    def _fetch_status_dict(self):
        rv = urlopen('https://map.boardconnect.aero/api/flightdata')
        if rv.code == 200:
            return json.load(rv)

    @property
    def is_online(self):
        # For now I have only observed inflight entertainment flights
        return False

    @property
    def flight_number(self):
        rv = (self.flight_number_raw or '').strip()
        if rv[:1] == 'D':
            rv = rv[1:]
        return rv or None

    @property
    def eta(self):
        d = self._get_status_dict()
        if not d:
            return None
        return d.get('timeDest')

    flight_number_raw = StatusProperty('flightNumber')
    aircraft_registration = StatusProperty('aircraftRegistration')
    orig_airport = StatusProperty('orig.code')
    dst_airport = StatusProperty('dest.code')
    ground_speed = StatusProperty('groundSpeed', ty=int)
    altitude = StatusProperty('altitude', ty=int)
    dist_to_dst = StatusProperty('distDest', ty=float)


class OebbTrainInfo(TrainInfo):

    def _fetch_status_dict(self):
        rv = urlopen('http://railnet.oebb.at/api/trainInfo')
        if rv.code == 200:
            return json.load(rv)

    is_online = True

    @property
    def train_number(self):
        d = self._get_status_dict() or {}
        line = d.get('lineNumber')
        train_type = d.get('trainType')
        if line and train_type:
            return '%s-%s' % (train_type, line)
        return str(train_type or line or '')

    @property
    def orig_station(self):
        d = self._get_status_dict() or {}
        return strip_station((d.get('start') or {}).get('all'))

    @property
    def dst_station(self):
        d = self._get_status_dict() or {}
        return strip_station((d.get('destination') or {}).get('all'))

    @property
    def eta(self):
        d = self._get_status_dict() or {}
        arrival = d.get('lastStationArrivalForecast')
        if not arrival:
            return
        now = datetime.datetime.now()

        arr_hour, arr_minutes = map(int, arrival.split(':'))

        min_arrival = arr_hour * 60 + arr_minutes
        min_now = now.hour * 60 + now.minute

        minutes = max(min_arrival, min_now) - min(min_now, min_arrival)
        return '%02d:%02d' % (
            minutes // 60,
            int(minutes % 60),
        )


def get_transport_info():
    info = get_wifi_info()
    if info.get('SSID') == 'myAustrian FlyNet':
        info = AustrianPlaneInfo()
    elif info.get('SSID') == 'Telekom_FlyNet':
        info = LufthansaPlaneInfo()
    elif info.get('SSID') == 'Aeroflot.entertainment':
        info = AeroflotPlaneInfo()
    elif info.get('SSID') == 'ACWiFi':
        info = AirCanadaPlaneInfo()
    elif info.get('SSID') == 'OEBB':
        info = OebbTrainInfo()
    else:
        return
    if info.is_available:
        return info


def prompt():
    info = get_transport_info()
    if info is None:
        return
    def _handle_match(m):
        x = m.group(1)
        if x == 'not_online_marker':
            if not info.is_online:
                return ' OFFLINE'
            return ''
        return str(getattr(info, x, None) or '')
    print(_pattern_re.sub(_handle_match, info.get_template()))


if __name__ == '__main__':
    prompt()
