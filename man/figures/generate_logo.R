library(hexSticker)
library(ggplot2)
library(showtext)

# Add Google Font
font_add_google("Open Sans", "opensans")
showtext_auto()

# ── Build a rising bar chart representing improving quality of care ──
bars <- data.frame(
  x = 1:4,
  y = c(0.3, 0.55, 0.75, 0.95),
  label = c("MIR", "YLL\n/YLD", "DAL\n/PER", "PER\n/INC")
)

# Color gradient from red (low quality) to green (high quality)
bar_colors <- c("#d73027", "#fc8d59", "#91cf60", "#1a9850")

p <- ggplot(bars, aes(x = x, y = y, fill = factor(x))) +
  geom_col(width = 0.7, color = NA) +
  scale_fill_manual(values = bar_colors) +
  coord_cartesian(ylim = c(0, 1.1)) +
  theme_void() +
  theme(legend.position = "none")

# ── Create hex sticker ──
sticker(
  p,
  package = "qci",
  p_size = 9,
  p_y = 1.45,
  p_color = "#1A3A1A",
  p_family = "opensans",
  p_fontface = "bold",
  s_x = 1.0,
  s_y = 0.75,
  s_width = 1.4,
  s_height = 0.9,
  h_fill = "#E8F5E9",
  h_color = "#1a9850",
  h_size = 1.8,
  url = "choxos.github.io/qci",
  u_size = 1.3,
  u_color = "#2E7D32",
  u_family = "opensans",
  filename = "man/figures/logo.svg",
  dpi = 300
)

# Also save as PNG
sticker(
  p,
  package = "qci",
  p_size = 9,
  p_y = 1.45,
  p_color = "#1A3A1A",
  p_family = "opensans",
  p_fontface = "bold",
  s_x = 1.0,
  s_y = 0.75,
  s_width = 1.4,
  s_height = 0.9,
  h_fill = "#E8F5E9",
  h_color = "#1a9850",
  h_size = 1.8,
  url = "choxos.github.io/qci",
  u_size = 1.3,
  u_color = "#2E7D32",
  u_family = "opensans",
  filename = "man/figures/logo.png",
  dpi = 300
)

cat("Logo generated successfully!\n")
