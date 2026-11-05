// Archived research-cover illustration; not used by the package.

/// Draw the small brain-and-connectome illustration used on research covers.
///
/// The drawing uses vector shapes so it stays crisp in print. The parameters
/// provide its primary ink, secondary accent, and paper colors; no text or
/// labels are included. This is an internal helper for `cover-page()`.
///
/// - ink (color): primary outline and neural paths
/// - accent (color): secondary nodes and connections
/// - paper (color): fill used to separate the brain shape from its background
/// -> content: a compact, right-aligned illustration
#let research-connectome(ink, accent, paper) = {
  let svg = (
    "<svg xmlns=\"http://www.w3.org/2000/svg\" width=\"360\" height=\"190\" viewBox=\"0 0 360 190\">" +
    "<path d=\"M77 119 C61 109 55 91 61 75 C67 58 82 46 101 41 C119 29 145 25 166 30 C184 25 204 32 216 44 C236 49 251 63 254 81 C260 97 249 111 233 117 C220 128 201 129 185 122 C170 131 151 129 137 120 C119 130 99 127 88 118 C84 120 80 120 77 119 Z M158 128 C160 144 166 158 173 168 C180 157 184 144 184 128\" fill=\"#ABCDEF\" fill-opacity=\".12\" stroke=\"#123456\" stroke-width=\"2.4\" stroke-linecap=\"round\" stroke-linejoin=\"round\"/>" +
    "<path d=\"M232 109 C243 101 256 105 260 115 C264 125 257 135 247 137 C237 139 229 132 228 122\" fill=\"none\" stroke=\"#123456\" stroke-width=\"2\" stroke-linecap=\"round\"/>" +
    "<g fill=\"none\" stroke=\"#ABCDEF\" stroke-width=\"2\" stroke-linecap=\"round\" opacity=\".92\">" +
    "<path d=\"M91 40 C105 32 117 40 117 51 C117 61 109 67 99 68 M139 25 C130 39 138 49 150 53 C160 57 163 67 155 75 M187 29 C176 40 181 51 191 57 C199 63 198 74 190 81 M239 48 C224 48 218 59 225 69 C231 78 227 87 217 92 M78 83 C93 77 105 84 104 96 C103 106 96 110 89 111 M133 96 C144 84 159 88 161 101 C163 112 155 119 145 121 M202 101 C193 90 179 93 177 105 C175 116 183 123 194 124\"/>" +
    "</g>" +
    "<g fill=\"none\" stroke=\"#123456\" stroke-width=\"1.5\" stroke-linecap=\"round\" opacity=\".76\">" +
    "<path d=\"M86 57L119 43L151 57L184 44L220 58L249 76 M69 88L105 91L139 83L171 94L208 83L246 99 M88 116L121 124L151 108L181 126L213 111L244 128 M86 57L105 91L88 116 M119 43L105 91L139 83L121 124 M151 57L139 83L171 94L151 108 M184 44L171 94L208 83L181 126 M220 58L208 83L246 99L244 128 M139 83L151 108L171 94L181 126 M208 83L213 111\"/>" +
    "</g>" +
    "<g fill=\"#FBFAF7\" stroke=\"#123456\" stroke-width=\"2\">" +
    "<circle cx=\"86\" cy=\"57\" r=\"4.5\"/><circle cx=\"119\" cy=\"43\" r=\"4.5\"/><circle cx=\"151\" cy=\"57\" r=\"4.5\"/><circle cx=\"184\" cy=\"44\" r=\"4.5\"/><circle cx=\"220\" cy=\"58\" r=\"4.5\"/>" +
    "<circle cx=\"69\" cy=\"88\" r=\"4.5\"/><circle cx=\"105\" cy=\"91\" r=\"4.5\"/><circle cx=\"139\" cy=\"83\" r=\"4.5\"/><circle cx=\"171\" cy=\"94\" r=\"4.5\"/><circle cx=\"208\" cy=\"83\" r=\"4.5\"/><circle cx=\"246\" cy=\"99\" r=\"4.5\"/>" +
    "<circle cx=\"88\" cy=\"116\" r=\"4.5\"/><circle cx=\"121\" cy=\"124\" r=\"4.5\"/><circle cx=\"151\" cy=\"108\" r=\"4.5\"/><circle cx=\"181\" cy=\"126\" r=\"4.5\"/><circle cx=\"213\" cy=\"111\" r=\"4.5\"/><circle cx=\"244\" cy=\"128\" r=\"4.5\"/>" +
    "</g></svg>"
  )
  image(
    bytes(svg.replace("#123456", ink.to-hex()).replace("#ABCDEF", accent.to-hex()).replace("#FBFAF7", paper.to-hex())),
    format: "svg",
    width: 8.5cm,
    alt: "Side-view brain illustration with connected neural nodes",
  )
}
