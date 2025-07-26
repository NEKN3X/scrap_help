import type { FuseResult, IFuseOptions } from 'fuse.js'
import Fuse from 'fuse.js'

export function search<T>(items: T[], query: string, options: IFuseOptions<T>): FuseResult<T>[] {
  const fuse = new Fuse(items, { ...options, includeScore: true, ignoreLocation: true, includeMatches: true })
  return fuse.search(query)
}
