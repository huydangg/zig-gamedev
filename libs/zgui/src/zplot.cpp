#include "imgui.h"
#include "implot.h"
#include "imgui_internal.h"

#ifndef ZGUI_API
#define ZGUI_API
#endif

//--------------------------------------------------------------------------------------------------
//
// ImPlot
//
//--------------------------------------------------------------------------------------------------
extern "C"
{
    ZGUI_API ImPlotContext *zguiPlot_CreateContext(void)
    {
        return ImPlot::CreateContext();
    }

    ZGUI_API void zguiPlot_DestroyContext(ImPlotContext *ctx)
    {
        ImPlot::DestroyContext(ctx);
    }

    ZGUI_API ImPlotContext *zguiPlot_GetCurrentContext(void)
    {
        return ImPlot::GetCurrentContext();
    }

    ZGUI_API ImPlotStyle zguiPlotStyle_Init(void)
    {
        return ImPlotStyle();
    }

    ZGUI_API ImPlotStyle *zguiPlot_GetStyle(void)
    {
        return &ImPlot::GetStyle();
    }

    ZGUI_API void zguiPlot_PushStyleColor4f(ImPlotCol idx, const float col[4])
    {
        ImPlot::PushStyleColor(idx, {col[0], col[1], col[2], col[3]});
    }

    ZGUI_API void zguiPlot_PushStyleColor1u(ImPlotCol idx, ImU32 col)
    {
        ImPlot::PushStyleColor(idx, col);
    }

    ZGUI_API void zguiPlot_PopStyleColor(int count)
    {
        ImPlot::PopStyleColor(count);
    }

    ZGUI_API void zguiPlot_PushStyleVar1i(ImPlotStyleVar idx, int var)
    {
        ImPlot::PushStyleVar(idx, var);
    }

    ZGUI_API void zguiPlot_PushStyleVar1f(ImPlotStyleVar idx, float var)
    {
        ImPlot::PushStyleVar(idx, var);
    }

    ZGUI_API void zguiPlot_PushStyleVar2f(ImPlotStyleVar idx, const float var[2])
    {
        ImPlot::PushStyleVar(idx, {var[0], var[1]});
    }

    ZGUI_API void zguiPlot_PopStyleVar(int count)
    {
        ImPlot::PopStyleVar(count);
    }

    ZGUI_API void zguiPlot_SetupLegend(ImPlotLocation location, ImPlotLegendFlags flags)
    {
        ImPlot::SetupLegend(location, flags);
    }

    ZGUI_API void zguiPlot_SetupAxis(ImAxis axis, const char *label, ImPlotAxisFlags flags)
    {
        ImPlot::SetupAxis(axis, label, flags);
    }

    ZGUI_API void zguiPlot_SetupAxisLimits(ImAxis axis, double v_min, double v_max, ImPlotCond cond)
    {
        ImPlot::SetupAxisLimits(axis, v_min, v_max, cond);
    }

    ZGUI_API void zguiPlot_SetupFinish(void)
    {
        ImPlot::SetupFinish();
    }

    ZGUI_API bool zguiPlot_BeginPlot(const char *title_id, float width, float height, ImPlotFlags flags)
    {
        return ImPlot::BeginPlot(title_id, {width, height}, flags);
    }

    ZGUI_API void zguiPlot_PlotLineValues(
        const char *label_id,
        ImGuiDataType data_type,
        const void *values,
        int count,
        double xscale,
        double x0,
        ImPlotLineFlags flags,
        int offset,
        int stride)
    {
        if (data_type == ImGuiDataType_S8)
            ImPlot::PlotLine(label_id, (const ImS8 *)values, count, xscale, x0, flags, offset, stride);
        else if (data_type == ImGuiDataType_U8)
            ImPlot::PlotLine(label_id, (const ImU8 *)values, count, xscale, x0, flags, offset, stride);
        else if (data_type == ImGuiDataType_S16)
            ImPlot::PlotLine(label_id, (const ImS16 *)values, count, xscale, x0, flags, offset, stride);
        else if (data_type == ImGuiDataType_U16)
            ImPlot::PlotLine(label_id, (const ImU16 *)values, count, xscale, x0, flags, offset, stride);
        else if (data_type == ImGuiDataType_S32)
            ImPlot::PlotLine(label_id, (const ImS32 *)values, count, xscale, x0, flags, offset, stride);
        else if (data_type == ImGuiDataType_U32)
            ImPlot::PlotLine(label_id, (const ImU32 *)values, count, xscale, x0, flags, offset, stride);
        else if (data_type == ImGuiDataType_Float)
            ImPlot::PlotLine(label_id, (const float *)values, count, xscale, x0, flags, offset, stride);
        else if (data_type == ImGuiDataType_Double)
            ImPlot::PlotLine(label_id, (const double *)values, count, xscale, x0, flags, offset, stride);
        else
            assert(false);
    }

    ZGUI_API void zguiPlot_PlotLine(
        const char *label_id,
        ImGuiDataType data_type,
        const void *xv,
        const void *yv,
        int count,
        ImPlotLineFlags flags,
        int offset,
        int stride)
    {
        if (data_type == ImGuiDataType_S8)
            ImPlot::PlotLine(label_id, (const ImS8 *)xv, (const ImS8 *)yv, count, flags, offset, stride);
        else if (data_type == ImGuiDataType_U8)
            ImPlot::PlotLine(label_id, (const ImU8 *)xv, (const ImU8 *)yv, count, flags, offset, stride);
        else if (data_type == ImGuiDataType_S16)
            ImPlot::PlotLine(label_id, (const ImS16 *)xv, (const ImS16 *)yv, count, flags, offset, stride);
        else if (data_type == ImGuiDataType_U16)
            ImPlot::PlotLine(label_id, (const ImU16 *)xv, (const ImU16 *)yv, count, flags, offset, stride);
        else if (data_type == ImGuiDataType_S32)
            ImPlot::PlotLine(label_id, (const ImS32 *)xv, (const ImS32 *)yv, count, flags, offset, stride);
        else if (data_type == ImGuiDataType_U32)
            ImPlot::PlotLine(label_id, (const ImU32 *)xv, (const ImU32 *)yv, count, flags, offset, stride);
        else if (data_type == ImGuiDataType_Float)
            ImPlot::PlotLine(label_id, (const float *)xv, (const float *)yv, count, flags, offset, stride);
        else if (data_type == ImGuiDataType_Double)
            ImPlot::PlotLine(label_id, (const double *)xv, (const double *)yv, count, flags, offset, stride);
        else
            assert(false);
    }

    ZGUI_API void zguiPlot_PlotScatter(
        const char *label_id,
        ImGuiDataType data_type,
        const void *xv,
        const void *yv,
        int count,
        ImPlotScatterFlags flags,
        int offset,
        int stride)
    {
        if (data_type == ImGuiDataType_S8)
            ImPlot::PlotScatter(label_id, (const ImS8 *)xv, (const ImS8 *)yv, count, flags, offset, stride);
        else if (data_type == ImGuiDataType_U8)
            ImPlot::PlotScatter(label_id, (const ImU8 *)xv, (const ImU8 *)yv, count, flags, offset, stride);
        else if (data_type == ImGuiDataType_S16)
            ImPlot::PlotScatter(label_id, (const ImS16 *)xv, (const ImS16 *)yv, count, flags, offset, stride);
        else if (data_type == ImGuiDataType_U16)
            ImPlot::PlotScatter(label_id, (const ImU16 *)xv, (const ImU16 *)yv, count, flags, offset, stride);
        else if (data_type == ImGuiDataType_S32)
            ImPlot::PlotScatter(label_id, (const ImS32 *)xv, (const ImS32 *)yv, count, flags, offset, stride);
        else if (data_type == ImGuiDataType_U32)
            ImPlot::PlotScatter(label_id, (const ImU32 *)xv, (const ImU32 *)yv, count, flags, offset, stride);
        else if (data_type == ImGuiDataType_Float)
            ImPlot::PlotScatter(label_id, (const float *)xv, (const float *)yv, count, flags, offset, stride);
        else if (data_type == ImGuiDataType_Double)
            ImPlot::PlotScatter(label_id, (const double *)xv, (const double *)yv, count, flags, offset, stride);
        else
            assert(false);
    }

    ZGUI_API void zguiPlot_PlotScatterValues(
        const char *label_id,
        ImGuiDataType data_type,
        const void *values,
        int count,
        double xscale,
        double x0,
        ImPlotScatterFlags flags,
        int offset,
        int stride)
    {
        if (data_type == ImGuiDataType_S8)
            ImPlot::PlotScatter(label_id, (const ImS8 *)values, count, xscale, x0, flags, offset, stride);
        else if (data_type == ImGuiDataType_U8)
            ImPlot::PlotScatter(label_id, (const ImU8 *)values, count, xscale, x0, flags, offset, stride);
        else if (data_type == ImGuiDataType_S16)
            ImPlot::PlotScatter(label_id, (const ImS16 *)values, count, xscale, x0, flags, offset, stride);
        else if (data_type == ImGuiDataType_U16)
            ImPlot::PlotScatter(label_id, (const ImU16 *)values, count, xscale, x0, flags, offset, stride);
        else if (data_type == ImGuiDataType_S32)
            ImPlot::PlotScatter(label_id, (const ImS32 *)values, count, xscale, x0, flags, offset, stride);
        else if (data_type == ImGuiDataType_U32)
            ImPlot::PlotScatter(label_id, (const ImU32 *)values, count, xscale, x0, flags, offset, stride);
        else if (data_type == ImGuiDataType_Float)
            ImPlot::PlotScatter(label_id, (const float *)values, count, xscale, x0, flags, offset, stride);
        else if (data_type == ImGuiDataType_Double)
            ImPlot::PlotScatter(label_id, (const double *)values, count, xscale, x0, flags, offset, stride);
        else
            assert(false);
    }

    ZGUI_API void zguiPlot_PlotShaded(
        const char *label_id,
        ImGuiDataType data_type,
        const void *xv,
        const void *yv,
        int count,
        double yref,
        ImPlotShadedFlags flags,
        int offset,
        int stride)
    {
        if (data_type == ImGuiDataType_S8)
            ImPlot::PlotShaded(label_id, (const ImS8 *)xv, (const ImS8 *)yv, count, yref, flags, offset, stride);
        else if (data_type == ImGuiDataType_U8)
            ImPlot::PlotShaded(label_id, (const ImU8 *)xv, (const ImU8 *)yv, count, yref, flags, offset, stride);
        else if (data_type == ImGuiDataType_S16)
            ImPlot::PlotShaded(label_id, (const ImS16 *)xv, (const ImS16 *)yv, count, yref, flags, offset, stride);
        else if (data_type == ImGuiDataType_U16)
            ImPlot::PlotShaded(label_id, (const ImU16 *)xv, (const ImU16 *)yv, count, yref, flags, offset, stride);
        else if (data_type == ImGuiDataType_S32)
            ImPlot::PlotShaded(label_id, (const ImS32 *)xv, (const ImS32 *)yv, count, yref, flags, offset, stride);
        else if (data_type == ImGuiDataType_U32)
            ImPlot::PlotShaded(label_id, (const ImU32 *)xv, (const ImU32 *)yv, count, yref, flags, offset, stride);
        else if (data_type == ImGuiDataType_Float)
            ImPlot::PlotShaded(label_id, (const float *)xv, (const float *)yv, count, yref, flags, offset, stride);
        else if (data_type == ImGuiDataType_Double)
            ImPlot::PlotShaded(label_id, (const double *)xv, (const double *)yv, count, yref, flags, offset, stride);
        else
            assert(false);
    }
    ZGUI_API void zguiPlot_PlotBars(
        const char *label_id,
        ImGuiDataType data_type,
        const void *xv,
        const void *yv,
        int count,
        double bar_size,
        ImPlotBarsFlags flags,
        int offset,
        int stride)
    {
        if (data_type == ImGuiDataType_S8)
            ImPlot::PlotBars(label_id, (const ImS8 *)xv, (const ImS8 *)yv, count, bar_size, flags, offset, stride);
        else if (data_type == ImGuiDataType_U8)
            ImPlot::PlotBars(label_id, (const ImU8 *)xv, (const ImU8 *)yv, count, bar_size, flags, offset, stride);
        else if (data_type == ImGuiDataType_S16)
            ImPlot::PlotBars(label_id, (const ImS16 *)xv, (const ImS16 *)yv, count, bar_size, flags, offset, stride);
        else if (data_type == ImGuiDataType_U16)
            ImPlot::PlotBars(label_id, (const ImU16 *)xv, (const ImU16 *)yv, count, bar_size, flags, offset, stride);
        else if (data_type == ImGuiDataType_S32)
            ImPlot::PlotBars(label_id, (const ImS32 *)xv, (const ImS32 *)yv, count, bar_size, flags, offset, stride);
        else if (data_type == ImGuiDataType_U32)
            ImPlot::PlotBars(label_id, (const ImU32 *)xv, (const ImU32 *)yv, count, bar_size, flags, offset, stride);
        else if (data_type == ImGuiDataType_Float)
            ImPlot::PlotBars(label_id, (const float *)xv, (const float *)yv, count, bar_size, flags, offset, stride);
        else if (data_type == ImGuiDataType_Double)
            ImPlot::PlotBars(label_id, (const double *)xv, (const double *)yv, count, bar_size, flags, offset, stride);
        else
            assert(false);
    }

    ZGUI_API void zguiPlot_PlotBarsValues(
        const char *label_id,
        ImGuiDataType data_type,
        const void *values,
        int count,
        double bar_size,
        double shift,
        ImPlotBarsFlags flags,
        int offset,
        int stride)
    {
        if (data_type == ImGuiDataType_S8)
            ImPlot::PlotBars(label_id, (const ImS8 *)values, count, bar_size, shift, flags, offset, stride);
        else if (data_type == ImGuiDataType_U8)
            ImPlot::PlotBars(label_id, (const ImU8 *)values, count, bar_size, shift, flags, offset, stride);
        else if (data_type == ImGuiDataType_S16)
            ImPlot::PlotBars(label_id, (const ImS16 *)values, count, bar_size, shift, flags, offset, stride);
        else if (data_type == ImGuiDataType_U16)
            ImPlot::PlotBars(label_id, (const ImU16 *)values, count, bar_size, shift, flags, offset, stride);
        else if (data_type == ImGuiDataType_S32)
            ImPlot::PlotBars(label_id, (const ImS32 *)values, count, bar_size, shift, flags, offset, stride);
        else if (data_type == ImGuiDataType_U32)
            ImPlot::PlotBars(label_id, (const ImU32 *)values, count, bar_size, shift, flags, offset, stride);
        else if (data_type == ImGuiDataType_Float)
            ImPlot::PlotBars(label_id, (const float *)values, count, bar_size, shift, flags, offset, stride);
        else if (data_type == ImGuiDataType_Double)
            ImPlot::PlotBars(label_id, (const double *)values, count, bar_size, shift, flags, offset, stride);
        else
            assert(false);
    }

    ZGUI_API bool zguiPlot_IsPlotHovered()
    {
        return ImPlot::IsPlotHovered();
    }
    ZGUI_API void zguiPlot_GetLastItemColor(float color[4])
    {
        const ImVec4 col = ImPlot::GetLastItemColor();
        color[0] = col.x;
        color[1] = col.y;
        color[2] = col.z;
        color[3] = col.w;
    }

    ZGUI_API void zguiPlot_ShowDemoWindow(bool *p_open)
    {
        ImPlot::ShowDemoWindow(p_open);
    }

    ZGUI_API void zguiPlot_EndPlot(void)
    {
        ImPlot::EndPlot();
    }

    ZGUI_API bool zguiPlot_DragPoint(
        int id,
        double *x,
        double *y,
        float col[4],
        float size,
        ImPlotDragToolFlags flags)
    {
        return ImPlot::DragPoint(
            id,
            x,
            y,
            (*(const ImVec4 *)&(col[0])),
            size,
            flags);
    }

    ZGUI_API void zguiPlot_PlotText(
        const char *text,
        double x, double y,
        const float pix_offset[2],
        ImPlotTextFlags flags = 0)
    {
        const ImVec2 p(pix_offset[0], pix_offset[1]);
        ImPlot::PlotText(text, x, y, p, flags);
    }

ZGUI_API int BinarySearch(const double *arr, int l, int r, double x) {
  if (r >= l) {
    int mid = l + (r - l) / 2;
    if (arr[mid] == x)
      return mid;
    if (arr[mid] > x)
      return BinarySearch(arr, l, mid - 1, x);
    return BinarySearch(arr, mid + 1, r, x);
  }
  return -1;
}

ZGUI_API void zguiPlot_SetupAxisFormat(ImAxis axis, const char *fmt) {
  ImPlot::SetupAxisFormat(axis, fmt);
};

// void SetupAxisScale(ImAxis idx, ImPlotScale scale)
ZGUI_API void zguiPlot_SetupAxisScale(ImAxis idx, ImPlotScale scale) {
  ImPlot::SetupAxisScale(idx, scale);
};

// // Sets an axis' limits constraints.
// IMPLOT_API void SetupAxisLimitsConstraints(ImAxis axis, double v_min, double
// v_max);
ZGUI_API void zguiPlot_SetupAxisLimitsConstraints(ImAxis axis, double v_min,
                                                  double v_max) {
  ImPlot::SetupAxisLimitsConstraints(axis, v_min, v_max);
}

// // Sets an axis' zoom constraints.
// IMPLOT_API void SetupAxisZoomConstraints(ImAxis axis, double z_min, double
// z_max);
ZGUI_API void zguiPlot_SetupAxisZoomConstraints(ImAxis axis, double z_min,
                                                double z_max) {
  ImPlot::SetupAxisZoomConstraints(axis, z_min, z_max);
}
ZGUI_API
void zguiPlot_PlotCandleStick(const char *label_id, int count, bool tooltip,
                              float width_percent, float bullCol[4],
                              float bearCol[4], const void *_xs,
                              const double *opens, const double *closes,
                              const double *lows, const double *highs) {
  const double *xs = (const double *)_xs;

  // get ImGui window DrawList
  ImDrawList *draw_list = ImPlot::GetPlotDrawList();
  // calc real value width
  double half_width =
      count > 1 ? (xs[1] - xs[0]) * width_percent : width_percent;
  // custom tool
  if (ImPlot::IsPlotHovered() && tooltip) {
    ImPlotPoint mouse = ImPlot::GetPlotMousePos();
    mouse.x =
        ImPlot::RoundTime(ImPlotTime::FromDouble(mouse.x), ImPlotTimeUnit_Day)
            .ToDouble();
    float tool_l = ImPlot::PlotToPixels(mouse.x - half_width * 1.5, mouse.y).x;
    float tool_r = ImPlot::PlotToPixels(mouse.x + half_width * 1.5, mouse.y).x;
    float tool_t = ImPlot::GetPlotPos().y;
    float tool_b = tool_t + ImPlot::GetPlotSize().y;
    ImPlot::PushPlotClipRect();
    draw_list->AddRectFilled(ImVec2(tool_l, tool_t), ImVec2(tool_r, tool_b),
                             IM_COL32(128, 128, 128, 64));
    ImPlot::PopPlotClipRect();
    // find mouse location index
    int idx = BinarySearch(xs, 0, count - 1, mouse.x);
    // render tool tip (won't be affected by plot clip rect)
    if (idx != -1) {
      ImGui::BeginTooltip();
      char buff[32];
      ImPlot::FormatDate(ImPlotTime::FromDouble(xs[idx]), buff, 32,
                         ImPlotDateFmt_DayMoYr, ImPlot::GetStyle().UseISO8601);
      ImGui::Text("Day:   %s", buff);
      ImGui::Text("Open:  $%.2f", opens[idx]);
      ImGui::Text("Close: $%.2f", closes[idx]);
      ImGui::Text("Low:   $%.2f", lows[idx]);
      ImGui::Text("High:  $%.2f", highs[idx]);
      ImGui::EndTooltip();
    }
  }

  // begin plot item
  if (ImPlot::BeginItem(label_id)) {
    // override legend icon color
    ImPlot::GetCurrentItem()->Color = IM_COL32(64, 64, 64, 255);

    ImPlotContext &gp = *GImPlot;
    ImPlotPoint plot_start =
        ImPlot::PixelsToPlot(gp.CurrentPlot->AxesRect.Min.x, 0);
    ImPlotPoint plot_end =
        ImPlot::PixelsToPlot(gp.CurrentPlot->AxesRect.Max.x, 0);
    // fit data if requested
    //
    if (ImPlot::FitThisFrame()) {
      for (int i = 0; i < count; ++i) {
        if (xs[i] >= plot_start.x && xs[i] <= plot_end.x) {
          ImPlot::FitPoint(ImPlotPoint(xs[i], lows[i]));
          ImPlot::FitPoint(ImPlotPoint(xs[i], highs[i]));
        }
      }
    }
    // render data
    for (int i = 0; i < count; ++i) {
      if (xs[i] >= plot_start.x && xs[i] <= plot_end.x) {
        ImVec2 open_pos = ImPlot::PlotToPixels(xs[i] - half_width, opens[i]);
        ImVec2 close_pos = ImPlot::PlotToPixels(xs[i] + half_width, closes[i]);
        ImVec2 low_pos = ImPlot::PlotToPixels(xs[i], lows[i]);
        ImVec2 high_pos = ImPlot::PlotToPixels(xs[i], highs[i]);
        // printf("open pos: %f, %f\n", open_pos.x, open_pos.y);
        ImU32 color = ImGui::GetColorU32(
            opens[i] > closes[i] ? (*(const ImVec4 *)&(bearCol[0]))
                                 : (*(const ImVec4 *)&(bullCol[0])));
        draw_list->AddLine(low_pos, high_pos, color);
        draw_list->AddRectFilled(open_pos, close_pos, color);
      }
    }

    // end plot item
    ImPlot::EndItem();
  }
}
} /* extern "C" */
