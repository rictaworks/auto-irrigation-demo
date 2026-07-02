"use client";

import Link from "next/link";
import { usePathname } from "next/navigation";
import { useTranslations } from "next-intl";
import { FontAwesomeIcon } from "@fortawesome/react-fontawesome";
import { faGauge, faDroplet, faSliders, faClockRotateLeft } from "@fortawesome/free-solid-svg-icons";
import { LocaleSwitcher } from "./LocaleSwitcher";

const NAV_ITEMS = [
  { href: "/", key: "dashboard", icon: faGauge },
  { href: "/sensor", key: "sensor", icon: faDroplet },
  { href: "/settings", key: "settings", icon: faSliders },
  { href: "/history", key: "history", icon: faClockRotateLeft },
] as const;

export function Nav() {
  const t = useTranslations("nav");
  const appT = useTranslations("app");
  const pathname = usePathname();

  return (
    <header className="nav-bar">
      <strong>{appT("title")}</strong>
      <nav className="nav-links">
        {NAV_ITEMS.map((item) => (
          <Link key={item.href} href={item.href} data-active={pathname === item.href}>
            <FontAwesomeIcon icon={item.icon} /> {t(item.key)}
          </Link>
        ))}
      </nav>
      <LocaleSwitcher />
    </header>
  );
}
