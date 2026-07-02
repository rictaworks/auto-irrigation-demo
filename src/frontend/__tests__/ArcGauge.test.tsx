import { render, screen } from "@testing-library/react";
import { ArcGauge } from "@/components/ArcGauge";

describe("ArcGauge", () => {
  it("値を丸めてパーセント表示する", () => {
    render(<ArcGauge value={32.4} label="Soil" />);
    expect(screen.getByText("32%")).toBeInTheDocument();
  });

  it("範囲外の値は0-100にクランプする", () => {
    render(<ArcGauge value={150} label="Soil" />);
    expect(screen.getByText("100%")).toBeInTheDocument();
  });
});
