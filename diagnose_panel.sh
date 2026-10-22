#!/usr/bin/env bash
# Диагностика «панель не открывается». Запуск на VPS: bash diagnose_panel.sh
set -uo pipefail
cd "$(dirname "$0")"

echo "=== IP сервера ==="
PUB=$(curl -4 -s --connect-timeout 3 ifconfig.me 2>/dev/null || true)
echo "Public IPv4: ${PUB:-unknown}"
hostname -I 2>/dev/null || true

echo ""
echo "=== Процесс mitm ==="
pgrep -af mitm_run_dump || echo "НЕТ процесса mitm_run_dump — запустите: nohup bash start_vps.sh >>/tmp/tbankmitm.log 2>&1 &"

echo ""
echo "=== Порт 8082 ==="
(ss -ltn 2>/dev/null || netstat -ltn 2>/dev/null) | grep ':8082 ' || echo "8082 НЕ слушается"

echo ""
echo "=== HTTP с VPS (без прокси) ==="
curl -s -o /dev/null -w "GET /admin -> HTTP %{http_code}\n" --connect-timeout 3 http://127.0.0.1:8082/admin || echo "curl failed"
curl -s -o /dev/null -w "GET /api/operations -> HTTP %{http_code}\n" --connect-timeout 3 http://127.0.0.1:8082/api/operations || true

echo ""
echo "=== Последние строки лога ==="
tail -15 /tmp/tbankmitm.log 2>/dev/null || echo "нет /tmp/tbankmitm.log"

echo ""
echo "Подсказки:"
echo "  • Панель: http://${PUB:-YOUR_IP}:8082/admin  (только http, не https)"
echo "  • На iPhone: выключите Potatso или добавьте IP VPS в bypass, иначе браузер ходит в прокси-петлю"
echo "  • Если 8082 не слушается: bash check_deploy.sh && TBANKMITM_APT=1 bash setup_linux.sh"
