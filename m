From: Nathan Straz <nstraz@sgi.com>
Date: Mon, 23 Jul 2001 14:07:50 +0000
Subject: Re: [Linux-ia64] XFS / IA64 system call conflict
Message-Id: <marc-linux-ia64-105590693005868@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590693005867@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590693005867@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Mon, Jul 23, 2001 at 03:53:06PM +0200, Martin Wilck wrote:
> David's last patch assigns the system call number 1215 to "getunwind".
> The XFS kernel patch for 2.4.5 vuses 1215-1217 for address control lists.
> How should this conflict be resolved? For now, I have just made XFS use
> 1216-1218 instead.

In the XFS CVS tree, the system calls have moved to the range 1260-1262.
We are in the process of getting some official numbers.

-- 
Nate Straz                                              nstraz@sgi.com
sgi, inc                                           http://www.sgi.com/
Linux Test Project                                  http://ltp.sf.net/

