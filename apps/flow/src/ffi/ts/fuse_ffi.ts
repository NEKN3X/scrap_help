import type { IFuseOptions } from 'fuse.js'
import Fuse from 'fuse.js'

export function search<T>(items: T[], query: string, options: IFuseOptions<T>): T[] {
  const fuse = new Fuse(items, options)
  return fuse.search(query).map(result => result.item)
}
