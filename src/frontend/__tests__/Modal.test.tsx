import { screen, fireEvent } from "@testing-library/react";
import { Modal } from "@/components/Modal";
import { renderWithIntl } from "../test-support/renderWithIntl";

describe("Modal", () => {
  it("isOpenがfalseなら何も描画しない", () => {
    renderWithIntl(
      <Modal isOpen={false} title="タイトル" onClose={jest.fn()}>
        本文
      </Modal>
    );
    expect(screen.queryByRole("dialog")).not.toBeInTheDocument();
  });

  it("isOpenがtrueならタイトルと本文を描画する", () => {
    renderWithIntl(
      <Modal isOpen title="確認" onClose={jest.fn()}>
        本当に実行しますか？
      </Modal>
    );
    expect(screen.getByRole("dialog")).toBeInTheDocument();
    expect(screen.getByText("確認")).toBeInTheDocument();
    expect(screen.getByText("本当に実行しますか？")).toBeInTheDocument();
  });

  it("オーバーレイクリックでonCloseが呼ばれる", () => {
    const onClose = jest.fn();
    renderWithIntl(
      <Modal isOpen title="確認" onClose={onClose}>
        本文
      </Modal>
    );
    fireEvent.click(screen.getByRole("dialog").parentElement as HTMLElement);
    expect(onClose).toHaveBeenCalled();
  });

  it("モーダル内部クリックではonCloseが呼ばれない", () => {
    const onClose = jest.fn();
    renderWithIntl(
      <Modal isOpen title="確認" onClose={onClose}>
        本文
      </Modal>
    );
    fireEvent.click(screen.getByRole("dialog"));
    expect(onClose).not.toHaveBeenCalled();
  });
});
