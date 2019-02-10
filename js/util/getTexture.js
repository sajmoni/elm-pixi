export default app => (filename) => {
  const {
    resources,
  } = app.loader;

  const texture = Object
    .values(resources)
    .filter(resource => resource.textures)
    .flatMap(resource => Object.entries(resource.textures))
    .find(([key]) => key === `${filename}.png`);

  if (!texture) throw new Error(`level1: Texture "${filename}" not found.`);

  return texture[1];
};
