" Vim syntax file
" Language:	MathML
" Filenames:	*.mml
" Maintainer:	Michal Gorny <michal-gorny@wp.pl>
" Last_change:	2006-03-23

" Quit when a syntax file was already loaded
if !exists("main_syntax")
  if exists("b:current_syntax")
    finish
  endif
  let main_syntax = 'mathml'
endif

if main_syntax == 'mathml'
  runtime! syntax/xml.vim
  syn cluster xmlTagHook add=mathmlElement
  syn cluster xmlAttribHook add=mathmlAttr
  syn match xmlDecl /\<\(<?\)\@<=xml\(-stylesheet\)\?\>/ containedin=xmlProcessing contained
  syn keyword xmlDeclAttr version encoding standalone containedin=xmlProcessing contained
  syn keyword xmlDeclAttr alternate charset media href title type containedin=xmlProcessing contained
else
  syn cluster xhtmlTagHook add=mathmlElement
  syn cluster xhtmlAttribHook add=mathmlAttr
endif

syn case match

" MathML elements
syn keyword mathmlElement contained abs and annotation apply approx arccos
syn keyword mathmlElement contained arccosh arccot arccoth arccsc arccsch arcsec
syn keyword mathmlElement contained arcsech arcsin arcsinh arctan arctanh arg
syn keyword mathmlElement contained bvar card cartesianproduct ceiling ci cn
syn keyword mathmlElement contained codomain complexes compose condition
syn keyword mathmlElement contained conjugate cos cosh cot coth csc csch csymbol
syn keyword mathmlElement contained curl declare degree determinant diff
syn keyword mathmlElement contained divergence divide domain domainofapplication
syn keyword mathmlElement contained emptyset encoding eq equivalent eulergamma
syn keyword mathmlElement contained exists exp exponentiale factorial factorof
syn keyword mathmlElement contained false floor fn forall function gcd geq grad
syn keyword mathmlElement contained gt ident image imaginary imaginaryi implies
syn keyword mathmlElement contained in infinity int integers intersect interval
syn keyword mathmlElement contained inverse lambda laplacian lcm leq limit list
syn keyword mathmlElement contained ln log logbase lowlimit lt maction malign
syn keyword mathmlElement contained maligngroup malignmark malignscope matrix
syn keyword mathmlElement contained matrixrow max mean median merror mfenced
syn keyword mathmlElement contained mfrac mi min minus mmultiscripts mn mo mode
syn keyword mathmlElement contained moment momentabout mover mpadded mphantom
syn keyword mathmlElement contained mprescripts mroot mrow ms mspace msqrt
syn keyword mathmlElement contained mstyle msub msubsup msup mtable mtd mtext
syn keyword mathmlElement contained mtr munder munderover naturalnumbers neq
syn keyword mathmlElement contained none not notanumber notin notprsubset
syn keyword mathmlElement contained notsubset or otherwise outerproduct
syn keyword mathmlElement contained partialdiff pi piece piecewice piecewise
syn keyword mathmlElement contained plus power primes product prsubset quotient
syn keyword mathmlElement contained rationals real reals reln rem root sdev
syn keyword mathmlElement contained scalarproduct sec sech selector semantics
syn keyword mathmlElement contained sep set setdiff sin sinh subset sum tan
syn keyword mathmlElement contained tanh tendsto times transpose true union
syn keyword mathmlElement contained uplimit variance vector vectorproduct xor
syn match   mathmlElement contained /\<annotation-xml\>/
syn match   mathmlElement contained /\<math\>[^:]/me=e-1

" Elements new in MathML 2.0
syn keyword mathmlAttr contained menclose mglyph mlabeledtr

" MathML attributes
syn keyword mathmlAttr contained accent accentunder actiontype align
syn keyword mathmlAttr contained alignmentscope alt axis background base
syn keyword mathmlAttr contained bevelled class close closure columnalign
syn keyword mathmlAttr contained columnalignment columnlines columnspacing
syn keyword mathmlAttr contained columnspan columnwidth definitionURL
syn keyword mathmlAttr contained denomalign depth display displaystyle edge
syn keyword mathmlAttr contained encoding equalcolumns equalrows fence
syn keyword mathmlAttr contained fontslant form frame framespacing
syn keyword mathmlAttr contained groupalign height href id index integer
syn keyword mathmlAttr contained largeop linebreak linethickness lquote
syn keyword mathmlAttr contained lspace macros mathbackground mathfamily
syn keyword mathmlAttr contained mathslant maxsize minlabelspacing minsize
syn keyword mathmlAttr contained mode monospaced movablelimits
syn keyword mathmlAttr contained movablescripts namedspace nargs notation
syn keyword mathmlAttr contained numalign number occurrence open order other
syn keyword mathmlAttr contained rowalign rowlines rowspacing rowspan rquote
syn keyword mathmlAttr contained rspace schemaLocation scope scriptlevel
syn keyword mathmlAttr contained scriptminsize scriptsizemultiplier
syn keyword mathmlAttr contained selection separator separators side
syn keyword mathmlAttr contained stretchy style subscriptshift symmetric
syn keyword mathmlAttr contained superscriptshift type width xmlns xref
syn match   mathmlAttr contained /\<\(background-color\|css-color-name\|css-fontfamily\|font-family\|h-unit\|html-color-name\|v-unit\)\>/
syn match   mathmlAttr contained /\<\(xml:\)\@<=space\>/

" Attributes new in MathML 2.0
syn keyword mathmlAttr contained mathcolor mathsize mathvariant mathweight

" Attributes deprecated in MathML 2.0
syn keyword mathmlAttr contained color fontfamily fontsize fontstyle fontweight

" Highlighting
hi link     xmlAttrib		Function
hi def link xmlDecl		Statement
hi def link xmlDeclAttr 	Type
hi link     xmlEntity		Special
hi link     xmlEntityPunct	Special
hi def link mathmlElement	Statement
hi def link mathmlAttr		Type

let b:current_syntax = "mathml"

if main_syntax == 'mathml'
  unlet main_syntax
endif

" vim: ts=8
