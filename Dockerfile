# Upstream's official DBX Web image, pinned (the stable release, not the nightly betas).
FROM t8y2/dbx:0.6.71

# One Railway volume at /app/data holds everything: the encrypted connection store,
# the secret key, installed drivers and plugins, and the scheduled backups.
ENV DBX_DATA_DIR=/app/data \
    DBX_BACKUP_ROOT=/app/data/backups

COPY --chmod=755 railway-entrypoint.sh /usr/local/bin/railway-entrypoint.sh
ENTRYPOINT ["/usr/local/bin/railway-entrypoint.sh"]
CMD ["dbx-web"]
