From: Kirill Korotaev <dev@sw.ru>
Date: Mon, 19 Mar 2007 12:50:13 +0000
Subject: Re: [IA64] unwind did not work for processes born with CLONE_STOPPED
Message-Id: <45FE8A5F.1080309@sw.ru>
List-Id: <linux-ia64.vger.kernel.org>
References: <45FE6E34.3070207@sw.ru>
In-Reply-To: <45FE6E34.3070207@sw.ru>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Christoph Hellwig wrote:
> On Mon, Mar 19, 2007 at 02:04:20PM +0300, Kirill Korotaev wrote:
> 
>>[IA64] unwind did not work for processes born with CLONE_STOPPED
>>
>>Minor problem for mainstream. Big problem for CPT,
> 
> 
> What is CPT?

It is checkpointing/restore feature from OpenVZ.
Sorry for confusion in the comment.

Kirill
