From: Keith Owens <kaos@sg.com>
Date: Wed, 14 May 2003 02:13:11 +0000
Subject: Re: [Linux-ia64] Dump driver module
Message-Id: <marc-linux-ia64-105590723705769@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590723705751@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590723705751@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Tue, 13 May 2003 16:39:30 +0200, 
Bruno Vidal <bruno_vidal@hp.com> wrote:
>Sorry, but LKCD is really not usefull because it use the buffer
>to write on the device. So it just hang in case of data page fault for
>example (because interuption are masked), LKCD is also not working in case
>of buffer corruption, disk driver pb, etc.... so LKCD is not usable in
>lot's of case (and it happen really often to have data page fault).

lkcd should not get data page faults.  Are you sure that is what you
are seeing and not some other problem that hangs lkcd?


