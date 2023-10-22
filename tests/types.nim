import std/options
import constructor/defaults

proc foo(x: Option[uint]): auto = x

type Settings {.defaults.} = object
  a = foo(10u.some)

implDefaults(Settings)

# import nimgl/[imgui]
# import constructor/defaults
# import kdl

# type # Config
#   SettingType* = enum
#     stInput # Input text
#     stCheck # Checkbox
#     stSlider # Int slider
#     stFSlider # Float slider
#     stSpin # Int spin
#     stFSpin # Float spin
#     stCombo
#     stRadio # Radio button
#     stRGB # Color edit RGB
#     stRGBA # Color edit RGBA
#     stSection
#     stFile # File picker
#     stFiles # Multiple files picker
#     stFolder # Folder picker

#   RGB* = tuple[r, g, b: range[0f..1f]]
#   RGBA* = tuple[r, g, b, a: range[0f..1f]]

#   # Because branches cannot have shared and additional fields right now (https://github.com/nim-lang/RFCs/issues/368)
#   # There are some weird field names in the object below
#   # S is the object for a section
#   Setting*[S: object or void] = object
#     display*: string
#     help*: string
#     case kind*: SettingType
#     of stInput:
#       inputVal*, inputDefault*, inputCache*: string
#       inputFlags*: seq[ImGuiInputTextFlags]
#       maxLength*: Option[uint]
#       hint*: string
#     of stCombo, stRadio:
#       comboRadioVal*, comboRadioDefault*, comboRadioCache*: string
#       comboFlags*: seq[ImGuiComboFlags]
#       items*: seq[string]
#     of stSection:
#       content*: S
#       sectionFlags*: seq[ImGuiTreeNodeFlags]
#     of stSlider:
#       sliderVal*, sliderDefault*, sliderCache*: int32
#       sliderFormat*: string
#       sliderRange*: Slice[int32]
#       sliderFlags*: seq[ImGuiSliderFlags]
#     of stFSlider:
#       fsliderVal*, fsliderDefault*, fsliderCache*: float32
#       fsliderFormat*: string
#       fsliderRange*: Slice[float32]
#       fsliderFlags*: seq[ImGuiSliderFlags]
#     of stSpin:
#       spinVal*, spinDefault*, spinCache*: int32
#       spinRange*: Slice[int32]
#       spinFlags*: seq[ImGuiInputTextFlags]
#       step*, stepFast*: int32
#     of stFSpin:
#       fspinVal*, fspinDefault*, fspinCache*: float32
#       fspinFormat*: string
#       fspinRange*: Slice[float32]
#       fspinFlags*: seq[ImGuiInputTextFlags]
#       fstep*, fstepFast*: float32
#     of stFile:
#       fileVal*, fileDefault*, fileCache*: string
#       fileFilterPatterns*: seq[string]
#       fileSingleFilterDescription*: string
#     of stFiles:
#       filesVal*, filesDefault*, filesCache*: seq[string]
#       filesFilterPatterns*: seq[string]
#       filesSingleFilterDescription*: string
#     of stFolder:
#       folderVal*, folderDefault*, folderCache*: string
#     of stCheck:
#       checkVal*, checkDefault*, checkCache*: bool
#     of stRGB:
#       rgbVal*, rgbDefault*, rgbCache*: RGB
#       rgbFlags*: seq[ImGuiColorEditFlags]
#     of stRGBA:
#       rgbaVal*, rgbaDefault*, rgbaCache*: RGBA
#       rgbaFlags*: seq[ImGuiColorEditFlags]

# proc inputSetting(display, help = "", default = "", hint = "", maxLength = uint.none, flags = newSeq[ImGuiInputTextFlags]()): Setting[void] =
#   ## If maxLength is none, the buffer size will be increased if the buffer also increases.
#   Setting[void](display: display, help: help, kind: stInput, inputDefault: default, hint: hint, maxLength: maxLength, inputFlags: flags)

# proc checkSetting(display, help = "", default: bool): Setting[void] =
#   Setting[void](display: display, help: help, kind: stCheck, checkDefault: default)

# proc comboSetting(display, help = "", items: seq[string], default: string, flags = newSeq[ImGuiComboFlags]()): Setting[void] =
#   Setting[void](display: display, help: help, kind: stCombo, items: items, comboRadioDefault: default, comboFlags: flags)

# type
#   Settings* {.defaults.} = object
#     a* = inputSetting(display = "Text Input")
#     b* = inputSetting(display = "Text Input With Hint", help = "Maximum 10 characters", hint = "type something", maxLength = some(10u))
#     c* = checkSetting(display = "Checkbox", default = false)
#     d* = comboSetting(display = "Combo", items = @["a", "b", "c"], default = "a")

# implDefaults(Settings)

