From: Ingo Molnar <mingo@elte.hu>
Date: Mon, 04 Feb 2002 19:22:33 +0000
Subject: Re: [Linux-ia64] O(1) MQ scheduler J9 patch for IA64
Message-Id: <marc-linux-ia64-105590698805985@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590698805977@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590698805977@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Mon, 4 Feb 2002, Erich Focht wrote:

> > Why is there a global change of current->processor to current->cpu?
> > That has knock on effects because #define cpu and references to that
> > macro also have to be changed.  I don't see any benefit.
>
> Keith,
> I can only guess that Ingo wanted to see the problematic spots when he
> compiles. I think there was a discussion on linux-kernel ML but I didn't
> follow it, so maybe Ingo can tell us...

the current->processor => current->cpu indeed was such a helper, to find
places that rely on p->cpu. (it's mostly code that has scheduling
relevance.)

renaming ->nice to ->__nice had another purpose, eg. in the -K2 patch
there is no 'nice' field anymore, ->static_prio is used.

	Ingo


