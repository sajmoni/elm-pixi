export default ({ on, displayObject, incoming }) => {
  if (on && on.length) {
    on.forEach(({ event, msg, value }) => {
      displayObject.on(event, () => {
        const toSend = { msg, value };
        incoming.send(toSend);
      });
    });
  }
};
