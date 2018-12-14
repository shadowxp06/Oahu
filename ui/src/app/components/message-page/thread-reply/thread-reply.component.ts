import {Component, OnInit, Input} from '@angular/core';
import {MessageType} from '../../../enums/message-type.enum';
import {APIService} from '../../../services/api/api.service';
import {PostReplyInterface} from '../../../interfaces/post-reply-interface';
import {faThumbsUp, faEdit, faStar, faLock} from '@fortawesome/free-solid-svg-icons';

@Component({
  selector: 'app-thread-reply',
  templateUrl: './thread-reply.component.html',
  styleUrls: ['./thread-reply.component.css']
})
export class ThreadReplyComponent implements OnInit {
  @Input() parentId: number;

  _replies: PostReplyInterface[] = [];

  numberOfReplies = 0;
  mt = MessageType;
  threadTitle = '';
  messageType = this.mt.all;
  faThumbsUp = faThumbsUp;
  faEdit = faEdit;
  faStar = faStar;
  faLock = faLock;

  constructor(private _api: APIService) { }

  ngOnInit() {
    if (this.parentId > 0) {
      this._api.getThreadReplies(this.parentId).subscribe(((data: PostReplyInterface[]) => {
        for (let i = 0; i < data.length; i++) {
          if (data[i].ID.toString() !== this.parentId.toString()) {
            if (data[i].ChildCount > 0) {
              data[i].ChildThreads = [];
              this._api.getThreadReplies(data[i].ID).subscribe( (childdata: PostReplyInterface[]) => {
                for (let n = 0; n < childdata.length; n++) {
                  if (childdata[n].ID.toString() !== data[i].ID.toString()) {
                    data[i].ChildThreads.push(childdata[n]);
                  }
                }
              });
            }
            this._replies.push(data[i]);
            this.numberOfReplies += 1;
          } else {
            this.numberOfReplies = data[i].ChildCount;
            this.threadTitle = data[i].Title;
            this.messageType = data[i].Type;
          }
        }
      }));
    }
  }
}
