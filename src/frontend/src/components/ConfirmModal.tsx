"use client";

import { useTranslations } from "next-intl";
import { Modal } from "./Modal";

interface ConfirmModalProps {
  isOpen: boolean;
  title: string;
  body: string;
  onConfirm: () => void;
  onCancel: () => void;
}

// window.confirm() の代替（緊急灌水モード等の重要な確認に使用）。
export function ConfirmModal({ isOpen, title, body, onConfirm, onCancel }: ConfirmModalProps) {
  const t = useTranslations("common");

  return (
    <Modal
      isOpen={isOpen}
      title={title}
      onClose={onCancel}
      actions={
        <>
          <button type="button" className="btn" onClick={onCancel}>
            {t("cancel")}
          </button>
          <button type="button" className="btn btn-primary" onClick={onConfirm}>
            {t("confirm")}
          </button>
        </>
      }
    >
      <p>{body}</p>
    </Modal>
  );
}
