From: Jes Sorensen <jes@wildopensource.com>
Date: Wed, 17 Sep 2003 14:33:47 +0000
Subject: Re: IA64 ino_t incorrectly sized?
Message-Id: <marc-linux-ia64-106380929812996@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-106378281914262@msgid-missing>
In-Reply-To: <marc-linux-ia64-106378281914262@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>>>>> "Nathan" = Nathan Scott <nathans@sgi.com> writes:

Nathan> Does anyone know why the IA64 platform-specific ino_t
Nathan> definition is an int and not a long?  Patch below fixes this
Nathan> problem for me but I wonder if there will be side-effects I
Nathan> haven't considered (i.e. was there a reason for making this 32
Nathan> bits originally?).  If not, could the IA64 maintainers push
Nathan> this patch around to the official kernel trees for me?
Nathan> (pretty please)

Hi Nathan,

I am actually surprised it's still a 32 bit int in the kernel. I
deliberately used 64 bit types in glibc so it could be done
right. Must have slipped on fixing the kernel for this one.

David?

Cheers,
Jes
