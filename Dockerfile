FROM stilliard/pure-ftpd


COPY autoconfig.sh /autoconfig.sh
COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh
ENTRYPOINT ["/entrypoint.sh"]

ENV PUBLICHOST localhost

# couple available volumes you may want to use
VOLUME ["/home/ftpusers", "/etc/pure-ftpd/passwd"]

# startup
CMD /run.sh -l puredb:/etc/pure-ftpd/pureftpd.pdb -E -j -R -P $PUBLICHOST

EXPOSE 21 30000-30009

#CMD ["/bin/bash"]