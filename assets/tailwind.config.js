// See the Tailwind configuration guide for advanced usage
// https://tailwindcss.com/docs/configuration

const plugin = require("tailwindcss/plugin")
const fs = require("fs")
const path = require("path")

module.exports = {
  content: [
    "./js/**/*.js",
    "../lib/eve_industrex_web.ex",
    "../lib/eve_industrex_web/**/*.*ex"
  ],
  theme: {
    extend: {
      height: {
        header: "var(--header-h)"
      },
      minHeight: {
        "screen-h": [
          "calc(100vh - var(--header-h))",
          "calc(100dvh - var(--header-h))",
        ]},
      colors: {
        brand: "#FD4F00",
        "system1.0": "#2e74de",
        "system0.9": "#389df1",
        "system0.8": "#62daa6",
        "system0.7": "#5cdba6",
        "system0.6": "#73e352",
        "system0.5": "#f0fe83",
        "system0.4": "#dc6b08",
        "system0.3": "#c94711",
        "system0.2": "#bb1012",
        "system0.1": "#6d211a",
        "system0.0": "#8f2f69",
        "rebeccapurple": '#663399',
        "peach": '#ffb6b9',
        "pinky": '#d291bc',
        "cream": '#fceabb',
      },
       backgroundImage: {
        'rebecca-gradient': 'linear-gradient(135deg, #663399, #d291bc, #fceabb)',
      },
      keyframes: {
        spin: {
          "0%": {
            transform: "rotateZ(0deg)"
          },
          "100%": {
            transform: "rotateZ(360deg)"
          }
        },
        fadein: {
          "0%":{
            opacity: 0
          },
          "100%":{
            opacity: 100
          }
        },
      },
      animations: {
        spin: "spin 0.1s ease infinite",
        fadein: "fadein 0.5s ease-in forwards"
      }
    },
  },
  plugins: [
    require("@tailwindcss/forms"),
    // Allows prefixing tailwind classes with LiveView classes to add rules
    // only when LiveView classes are applied, for example:
    //
    //     <div class="phx-click-loading:animate-ping">
    //
    plugin(({addVariant}) => addVariant("phx-click-loading", [".phx-click-loading&", ".phx-click-loading &"])),
    plugin(({addVariant}) => addVariant("phx-submit-loading", [".phx-submit-loading&", ".phx-submit-loading &"])),
    plugin(({addVariant}) => addVariant("phx-change-loading", [".phx-change-loading&", ".phx-change-loading &"])),

    // Embeds Heroicons (https://heroicons.com) into your app.css bundle
    // See your `CoreComponents.icon/1` for more information.
    //
    plugin(function({matchComponents, theme}) {
      let iconsDir = path.join(__dirname, "../deps/heroicons/optimized")
      let values = {}
      let icons = [
        ["", "/24/outline"],
        ["-solid", "/24/solid"],
        ["-mini", "/20/solid"],
        ["-micro", "/16/solid"]
      ]
      icons.forEach(([suffix, dir]) => {
        fs.readdirSync(path.join(iconsDir, dir)).forEach(file => {
          let name = path.basename(file, ".svg") + suffix
          values[name] = {name, fullPath: path.join(iconsDir, dir, file)}
        })
      })
      matchComponents({
        "hero": ({name, fullPath}) => {
          let content = fs.readFileSync(fullPath).toString().replace(/\r?\n|\r/g, "")
          let size = theme("spacing.6")
          if (name.endsWith("-mini")) {
            size = theme("spacing.5")
          } else if (name.endsWith("-micro")) {
            size = theme("spacing.4")
          }
          return {
            [`--hero-${name}`]: `url('data:image/svg+xml;utf8,${content}')`,
            "-webkit-mask": `var(--hero-${name})`,
            "mask": `var(--hero-${name})`,
            "mask-repeat": "no-repeat",
            "background-color": "currentColor",
            "vertical-align": "middle",
            "display": "inline-block",
            "width": size,
            "height": size
          }
        }
      }, {values})
    })
  ]
}
