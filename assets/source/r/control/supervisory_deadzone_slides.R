library(ggplot2)
library(tibble)
library(dplyr)
library(scales)
library(grid)

# ==========================================================
# Supervisory deadzone — slide version
#
# Conceptual figure, not experimental data.
#
# Implemented logic represented:
#   |e[k]| < eps_dead                       -> IDLE
#   |e[k]| >= eps_dead, Delta r > eps_dr   -> FLEX
#   |e[k]| >= eps_dead, Delta r < -eps_dr  -> EXT
#   otherwise                              -> previous state
#
# Notes:
# - The gray ribbon is ONLY the tracking deadzone.
# - FLEX / EXT direction is selected from the reference increment.
# - IDLE denotes a zero-command interval, not a measured thermal state.
# ==========================================================


# ----------------------------------------------------------
# 1. Illustrative supervisory parameters
# ----------------------------------------------------------

eps_dead <- 2.0
eps_dr   <- 0.001   # deg/sample

t <- seq(
  0,
  8,
  length.out = 600
)

theta_ref <-
  90 +
  6.5 * sin(
    2 * pi * t / 8 + 0.15
  )

theta_meas <-
  90 +
  5.8 * sin(
    2 * pi * t / 8 - 0.25
  )


# ----------------------------------------------------------
# 2. Signals
# ----------------------------------------------------------

df <- tibble(
  t    = t,
  ref  = theta_ref,
  meas = theta_meas
) %>%
  mutate(
    error     = ref - meas,
    delta_ref = c(0, diff(ref)),
    upper     = ref + eps_dead,
    lower     = ref - eps_dead
  )


# ----------------------------------------------------------
# 3. Implemented State Manager law
# ----------------------------------------------------------

state <- character(
  nrow(df)
)

state[1] <- "IDLE"

for (k in 2:nrow(df)) {

  if (
    abs(df$error[k]) < eps_dead
  ) {

    state[k] <- "IDLE"

  } else if (
    df$delta_ref[k] > eps_dr
  ) {

    state[k] <- "FLEX"

  } else if (
    df$delta_ref[k] < -eps_dr
  ) {

    state[k] <- "EXT"

  } else {

    # Persistent state:
    # outside the deadzone but without a new
    # reference-direction decision.
    state[k] <- state[k - 1]
  }
}

df$state <- factor(
  state,
  levels = c(
    "FLEX",
    "IDLE",
    "EXT"
  )
)


# ----------------------------------------------------------
# 4. Convert state sequence into continuous time segments
# ----------------------------------------------------------

start_idx <- c(
  1,
  which(
    df$state[-1] !=
      df$state[-nrow(df)]
  ) + 1
)

state_segments <- tibble(
  xmin = df$t[start_idx],

  xmax = c(
    df$t[start_idx[-1]],
    max(df$t)
  ),

  state = df$state[start_idx]
)


# ==========================================================
# 5. Slide palette
# ==========================================================

# Signals
col_reference <- "#2563EB"
col_measured  <- "#111827"

# Deadzone
col_band      <- "#E5E7EB"
col_band_edge <- "#94A3B8"

# State convention
col_flex <- "#C2185B"
col_idle <- "#E5E7EB"
col_ext  <- "#007C91"

# Neutral styling
col_text  <- "#1F2933"
col_muted <- "#66757D"
col_axis  <- "#94A3B8"
col_grid  <- "#E8EEF0"
col_white <- "#FFFFFF"


# ==========================================================
# 6. Shared slide theme
# ==========================================================

theme_supervisory_slide <- function(
    base_size = 14
) {

  theme_minimal(
    base_size = base_size,
    base_family = "sans"
  ) +

    theme(

      # -----------------------------------------------
      # Plot surface
      # -----------------------------------------------

      panel.background = element_rect(
        fill = col_white,
        color = NA
      ),

      plot.background = element_rect(
        fill = "transparent",
        color = NA
      ),

      # -----------------------------------------------
      # Grid
      # -----------------------------------------------

      panel.grid.minor =
        element_blank(),

      panel.grid.major.x =
        element_blank(),

      panel.grid.major.y =
        element_line(
          color = col_grid,
          linewidth = 0.42
        ),

      # -----------------------------------------------
      # Axes
      # -----------------------------------------------

      axis.line.x =
        element_line(
          color = col_axis,
          linewidth = 0.45
        ),

      axis.ticks.x =
        element_line(
          color = col_axis,
          linewidth = 0.40
        ),

      axis.ticks.y =
        element_blank(),

      axis.ticks.length =
        unit(
          2.2,
          "pt"
        ),

      axis.title =
        element_text(
          color = col_text,
          size = 12,
          face = "bold"
        ),

      axis.text =
        element_text(
          color = col_text,
          size = 11
        ),

      # -----------------------------------------------
      # Legend
      # -----------------------------------------------

      legend.title =
        element_blank(),

      legend.text =
        element_text(
          color = col_text,
          size = 12.5
        ),

      legend.key =
        element_blank(),

      legend.background =
        element_blank(),

      legend.box.background =
        element_blank(),

      legend.spacing.x =
        unit(
          0.20,
          "cm"
        ),

      legend.key.width =
        unit(
          1.05,
          "cm"
        ),

      legend.key.height =
        unit(
          0.32,
          "cm"
        )
    )
}


# ==========================================================
# 7. TOP PANEL
# Reference + measured angle + symmetric deadzone
# ==========================================================

p_tracking <-
  ggplot(
    df,
    aes(x = t)
  ) +

  # --------------------------------------------------------
  # Deadzone ribbon
  # --------------------------------------------------------

  geom_ribbon(
    aes(
      ymin = lower,
      ymax = upper,
      fill = "Deadzone"
    ),
    alpha = 0.82,
    show.legend = TRUE
  ) +

  # --------------------------------------------------------
  # Deadzone boundaries
  # --------------------------------------------------------

  geom_line(
    aes(
      y = upper
    ),
    color = col_band_edge,
    linewidth = 0.62,
    linetype = "22",
    show.legend = FALSE
  ) +

  geom_line(
    aes(
      y = lower
    ),
    color = col_band_edge,
    linewidth = 0.62,
    linetype = "22",
    show.legend = FALSE
  ) +

  # --------------------------------------------------------
  # Reference
  # --------------------------------------------------------

  geom_line(
    aes(
      y = ref,
      color = "Reference"
    ),
    linewidth = 1.18
  ) +

  # --------------------------------------------------------
  # Measured response
  # --------------------------------------------------------

  geom_line(
    aes(
      y = meas,
      color = "Measured"
    ),
    linewidth = 1.05
  ) +

  # --------------------------------------------------------
  # Signal legend
  # --------------------------------------------------------

  scale_color_manual(
    values = c(
      "Reference" = col_reference,
      "Measured"  = col_measured
    ),
    breaks = c(
      "Reference",
      "Measured"
    )
  ) +

  # --------------------------------------------------------
  # Deadzone legend
  # --------------------------------------------------------

  scale_fill_manual(
    values = c(
      "Deadzone" = col_band
    ),
    breaks = "Deadzone",
    labels = expression(
      "Deadzone  " *
        r[k] %+-% epsilon[deadzone]
    )
  ) +

  guides(

    color = guide_legend(
      order = 1,
      override.aes = list(
        linewidth = 1.35
      )
    ),

    fill = guide_legend(
      order = 2,
      override.aes = list(
        alpha = 0.82
      )
    )
  ) +

  # --------------------------------------------------------
  # X axis
  # --------------------------------------------------------

  scale_x_continuous(
    limits = range(
      df$t
    ),

    expand = c(
      0,
      0
    ),

    breaks = seq(
      min(df$t),
      max(df$t),
      by = 2
    )
  ) +

  # --------------------------------------------------------
  # Y axis
  # --------------------------------------------------------

  scale_y_continuous(
    breaks = seq(
      80,
      100,
      by = 5
    ),

    expand =
      expansion(
        mult = c(
          0.015,
          0.025
        )
      )
  ) +

  labs(
    x = NULL,
    y = expression(
      theta~"(deg)"
    )
  ) +

  coord_cartesian(

    ylim =
      range(
        c(
          df$lower,
          df$upper
        )
      ) +
      c(
        -1.2,
        1.2
      ),

    clip = "off"
  ) +

  theme_supervisory_slide(
    base_size = 14
  ) +

  theme(

    # -----------------------------------------------
    # Legend outside the data region
    # -----------------------------------------------

    legend.position =
      "top",

    legend.justification =
      "left",

    legend.direction =
      "horizontal",

    legend.box =
      "horizontal",

    legend.box.just =
      "left",

    legend.margin =
      margin(
        t = 0,
        r = 0,
        b = 1,
        l = 0
      ),

    # -----------------------------------------------
    # Y axis
    # -----------------------------------------------

    axis.title.y =
      element_text(
        margin = margin(
          r = 8
        )
      ),

    # -----------------------------------------------
    # X axis shown only below
    # -----------------------------------------------

    axis.text.x =
      element_blank(),

    axis.ticks.x =
      element_blank(),

    axis.line.x =
      element_blank(),

    # -----------------------------------------------
    # Panel spacing
    # -----------------------------------------------

    plot.margin =
      margin(
        t = 2,
        r = 10,
        b = 1,
        l = 8
      )
  )


# ==========================================================
# 8. LOWER PANEL
# Actual State Manager request
# ==========================================================

p_state <-
  ggplot(
    state_segments
  ) +

  geom_rect(
    aes(
      xmin = xmin,
      xmax = xmax,
      ymin = 0,
      ymax = 1,
      fill = state
    ),
    color = NA
  ) +

  # --------------------------------------------------------
  # State colors
  # --------------------------------------------------------

  scale_fill_manual(

    values = c(
      "FLEX" = col_flex,
      "IDLE" = col_idle,
      "EXT"  = col_ext
    ),

    breaks = c(
      "FLEX",
      "IDLE",
      "EXT"
    ),

    labels = c(
      "FLEX",
      "IDLE",
      "EXT"
    )
  ) +

  # --------------------------------------------------------
  # X axis
  # --------------------------------------------------------

  scale_x_continuous(

    limits =
      range(
        df$t
      ),

    expand = c(
      0,
      0
    ),

    breaks = seq(
      min(df$t),
      max(df$t),
      by = 2
    )
  ) +

  # --------------------------------------------------------
  # State strip vertical extent
  # --------------------------------------------------------

  scale_y_continuous(

    limits = c(
      0,
      1
    ),

    expand = c(
      0,
      0
    )
  ) +

  labs(
    x = "Time (s)",
    y = "State"
  ) +

  theme_supervisory_slide(
    base_size = 14
  ) +

  theme(

    # -----------------------------------------------
    # State legend
    # -----------------------------------------------

    legend.position =
      "bottom",

    legend.justification =
      "center",

    legend.direction =
      "horizontal",

    legend.text =
      element_text(
        color = col_text,
        size = 12,
        face = "bold"
      ),

    legend.key.width =
      unit(
        0.75,
        "cm"
      ),

    legend.key.height =
      unit(
        0.30,
        "cm"
      ),

    legend.margin =
      margin(
        t = 1,
        r = 0,
        b = 0,
        l = 0
      ),

    # -----------------------------------------------
    # No grid inside categorical strip
    # -----------------------------------------------

    panel.grid =
      element_blank(),

    # -----------------------------------------------
    # X axis
    # -----------------------------------------------

    axis.title.x =
      element_text(
        size = 12,
        margin = margin(
          t = 6
        )
      ),

    axis.text.x =
      element_text(
        size = 11
      ),

    # -----------------------------------------------
    # Y axis
    # -----------------------------------------------

    axis.title.y =
      element_text(
        size = 11.5,
        margin = margin(
          r = 8
        )
      ),

    axis.text.y =
      element_blank(),

    axis.ticks.y =
      element_blank(),

    # -----------------------------------------------
    # Panel spacing
    # -----------------------------------------------

    plot.margin =
      margin(
        t = 1,
        r = 10,
        b = 2,
        l = 8
      )
  )


# ==========================================================
# 9. Export settings
# ==========================================================

out_dir <- file.path(
  "assets",
  "figures",
  "control"
)

dir.create(
  out_dir,
  recursive = TRUE,
  showWarnings = FALSE
)

pdf_file <- file.path(
  out_dir,
  "supervisory_deadzone_slides.pdf"
)

svg_file <- file.path(
  out_dir,
  "supervisory_deadzone_slides.svg"
)

png_file <- file.path(
  out_dir,
  "supervisory_deadzone_slides.png"
)


# ----------------------------------------------------------
# Slide-oriented aspect ratio
# ----------------------------------------------------------

fig_width  <- 9.6
fig_height <- 5.2


# ==========================================================
# 10. Combined figure layout
# ==========================================================

draw_combined_figure <- function() {

  grid.newpage()

  layout <-
    grid.layout(

      nrow = 2,
      ncol = 1,

      heights = unit(
        c(
          4.15,
          1.20
        ),
        "null"
      )
    )

  pushViewport(
    viewport(
      layout = layout
    )
  )

  print(
    p_tracking,

    vp = viewport(
      layout.pos.row = 1,
      layout.pos.col = 1
    )
  )

  print(
    p_state,

    vp = viewport(
      layout.pos.row = 2,
      layout.pos.col = 1
    )
  )
}


# ==========================================================
# 11. PDF export
# ==========================================================

if (
  capabilities(
    "cairo"
  )
) {

  grDevices::cairo_pdf(
    filename = pdf_file,
    width = fig_width,
    height = fig_height,
    bg = "transparent"
  )

} else {

  grDevices::pdf(
    file = pdf_file,
    width = fig_width,
    height = fig_height,
    useDingbats = FALSE,
    version = "1.4",
    bg = "transparent"
  )
}

draw_combined_figure()

dev.off()

message(
  "Created PDF: ",
  pdf_file
)


# ==========================================================
# 12. SVG export
# Requires package: svglite
#
# install.packages("svglite")
# ==========================================================

if (
  requireNamespace(
    "svglite",
    quietly = TRUE
  )
) {

  svglite::svglite(
    file = svg_file,
    width = fig_width,
    height = fig_height,
    bg = "transparent"
  )

  draw_combined_figure()

  dev.off()

  message(
    "Created SVG: ",
    svg_file
  )

} else {

  message(
    "SVG not created because package 'svglite' is not installed."
  )
}


# ==========================================================
# 13. PNG preview export
# Useful only for quick visual inspection
# ==========================================================

grDevices::png(
  filename = png_file,
  width = fig_width,
  height = fig_height,
  units = "in",
  res = 180,
  bg = "white"
)

draw_combined_figure()

dev.off()

message(
  "Created PNG: ",
  png_file
)