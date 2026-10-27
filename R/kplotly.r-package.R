#' @keywords internal
"_PACKAGE"

# Internal registries (types, themes, palettes), filled in .onLoad().
.kply <- new.env(parent = emptyenv())

.onLoad <- function(libname, pkgname) {
  .kply$types <- list()
  .kply$themes <- list()
  .kply$palettes <- list()
  register_builtin_palettes()
  register_builtin_themes()
  register_builtin_types()
}
NULL
