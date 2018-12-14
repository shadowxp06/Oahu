/* Remove this in favor of Post interface */
export interface Draftsinterface {
  messageId: number;
  title: string;
  lastupdated: string;
  authorid: number;
  coauthors?: DraftCoAuthorInterface[];
}

export interface DraftCoAuthorInterface {
  authorId: number;
}
