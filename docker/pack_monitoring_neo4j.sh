#!/usr/bin/env bash
set -euo pipefail

OUTDIR="./exported_volumes"
mkdir -p "$OUTDIR"
TS=$(date +%F_%H%M)

echo "Export dir: $OUTDIR"

# Попытка сделать logical dump neo4j (если контейнер запущен и в нём есть neo4j-admin)
if docker compose ps neo4j >/dev/null 2>&1; then
  echo "Попытка neo4j-admin dump (если доступен)..."
  if docker compose exec neo4j sh -c 'command -v neo4j-admin >/dev/null 2>&1'; then
    docker compose exec neo4j neo4j-admin dump --database=neo4j --to="/tmp/neo4j_${TS}.dump" || echo "neo4j-admin dump вернул ошибку"
    docker compose cp neo4j:/tmp/neo4j_${TS}.dump "${OUTDIR}/neo4j_${TS}.dump" || echo "Не удалось скопировать neo4j dump"
  else
    echo "neo4j-admin не найден в контейнере — пропускаем logical dump"
  fi
else
  echo "Контейнер neo4j не запущен — пропускаем neo4j dump"
fi

VOLUMES=(
  bdprod_neo4j_data
  bdprod_neo4j_plugins
  bdprod_grafana_data
)

for VOL in "${VOLUMES[@]}"; do
  if docker volume inspect "$VOL" >/dev/null 2>&1; then
    OUT="${OUTDIR}/${VOL}_${TS}.tar.gz"
    echo "Packing volume $VOL -> $OUT"
    docker run --rm -v "${VOL}":/volume -v "$(pwd)/${OUTDIR}":/backup alpine \
      sh -c "cd /volume && tar czf /backup/$(basename "$OUT") ."
    sha256sum "${OUT}" > "${OUT}.sha256"
  else
    echo "Volume $VOL not found — пропускаем"
  fi
done

# pack monitoring folder if exists
if [ -d "./monitoring" ]; then
  OUT="${OUTDIR}/monitoring_${TS}.tar.gz"
  echo "Packing ./monitoring -> ${OUT}"
  tar czf "${OUT}" -C . monitoring
  sha256sum "${OUT}" > "${OUT}.sha256"
fi

# single archive for transfer
ARCHIVE="./export_${TS}.tar.gz"
tar czf "${ARCHIVE}" -C "${OUTDIR}" .
sha256sum "${ARCHIVE}" > "${ARCHIVE}.sha256"

echo "Done. Archive: ${ARCHIVE}"
echo "Files in ${OUTDIR}:"
ls -lh "${OUTDIR}"
