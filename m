From: Jim Wilson <wilson@cygnus.com>
Date: Tue, 16 Jan 2001 02:02:52 +0000
Subject: Re: [Linux-ia64] [PATCH] Fix for kernel DRM build
Message-Id: <marc-linux-ia64-105590693005049@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590678205902@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590678205902@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>Does that work with an empty archive or an archive with files of
>mixed types? I thought about your approach. But I decided against
>it since it didn't work with the cases above.

No, but I don't see how we can make those cases work in a reasonable fashion,
except to give an error, and hence the user should not expect them to work.
If there are linux kernel Makefiles that do this, then I would consider them
broken.

If you want to argue for your solution, then you should make this argument
on the binutils@sources.redhat.com list, as that is where the issue will be
decided.

Jim

