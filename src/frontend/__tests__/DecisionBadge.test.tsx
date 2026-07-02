import { screen } from "@testing-library/react";
import { DecisionBadge } from "@/components/DecisionBadge";
import { renderWithIntl } from "../test-support/renderWithIntl";

describe("DecisionBadge", () => {
  it("immediateは「今すぐ灌水」と表示する", () => {
    renderWithIntl(<DecisionBadge level="immediate" />);
    expect(screen.getByText("今すぐ灌水")).toBeInTheDocument();
  });

  it("noneは「灌水不要」と表示する", () => {
    renderWithIntl(<DecisionBadge level="none" />);
    expect(screen.getByText("灌水不要")).toBeInTheDocument();
  });
});
