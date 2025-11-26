#import "@preview/tufted:0.0.1": *

#let template = tufted-web.with(
  header-links: (
    "/": "Home",
    "/posts/": "Posts",
    "/about/": "About",
  ),
  title: "Math Diary",
)
