"use client";

import type { ReactNode } from "react";

interface ModalProps {
  isOpen: boolean;
  title: string;
  onClose: () => void;
  children?: ReactNode;
  actions?: ReactNode;
}

// ネイティブ alert()/confirm()/prompt() の代替となる共通モーダル(coding-style.md)。
export function Modal({ isOpen, title, onClose, children, actions }: ModalProps) {
  if (!isOpen) return null;

  return (
    <div className="modal-overlay" onClick={onClose}>
      <div
        className="modal-box"
        role="dialog"
        aria-modal="true"
        aria-labelledby="modal-title"
        onClick={(event) => event.stopPropagation()}
      >
        <h2 id="modal-title">{title}</h2>
        <div>{children}</div>
        <div className="modal-actions">{actions}</div>
      </div>
    </div>
  );
}
