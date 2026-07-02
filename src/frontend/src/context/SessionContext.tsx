"use client";

import { createContext, useContext, useEffect, useState, type ReactNode } from "react";
import { apiClient } from "@/lib/api";

interface SessionState {
  sessionId: string | null;
  isLoading: boolean;
  error: Error | null;
}

const initialState: SessionState = { sessionId: null, isLoading: true, error: null };

const SessionContext = createContext<SessionState>(initialState);

// ページロード時にセッション確認・自動発行を行う(README.md「自動ログイン」)。
export function SessionProvider({ children }: { children: ReactNode }) {
  const [state, setState] = useState<SessionState>(initialState);

  useEffect(() => {
    let cancelled = false;

    apiClient
      .getSession()
      .then((response) => {
        if (!cancelled) {
          setState({ sessionId: response.session_id, isLoading: false, error: null });
        }
      })
      .catch((err: unknown) => {
        if (!cancelled) {
          setState({
            sessionId: null,
            isLoading: false,
            error: err instanceof Error ? err : new Error(String(err)),
          });
        }
      });

    return () => {
      cancelled = true;
    };
  }, []);

  return <SessionContext.Provider value={state}>{children}</SessionContext.Provider>;
}

export function useSession(): SessionState {
  return useContext(SessionContext);
}
