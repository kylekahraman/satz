/// Scope figure, table and equation numbers to a chapter or appendix.
/// The chapter is captured in each element's numbering function, so references
/// from other chapters keep the target's prefix instead of the caller's.
/// Put a chapter's headings and content inside this scope; heading numbering
/// and chapter page breaks remain the document class's responsibility.
#let chapter-numbering(body, chapter: 1, appendix: false) = {
  assert(type(chapter) == int and chapter > 0, message: "chapter must be a positive integer")
  let figure-format = (n) => numbering(if appendix { "A.1" } else { "1.1" }, chapter, n)
  let equation-format = (n) => numbering(if appendix { "(A.1)" } else { "(1.1)" }, chapter, n)
  set figure(numbering: figure-format)
  set math.equation(numbering: equation-format)
  counter(figure.where(kind: image)).update(0)
  counter(figure.where(kind: table)).update(0)
  counter(math.equation).update(0)
  body
}
