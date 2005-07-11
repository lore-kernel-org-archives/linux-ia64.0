From: david mosberger <dmosberger@gmail.com>
Date: Mon, 11 Jul 2005 23:00:17 +0000
Subject: curious compiler-warning
Message-Id: <ed5aea430507111600684085cc@mail.gmail.com>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Hi Jim,

I tried to make the ia64-specific files in the Linux kernel compile
cleanly with gcc v4.0.1 and ended up with this curious warning
message:

arch/ia64/kernel/time.c:198: warning: format '%u' expects type
'unsigned int', but argument 5 has type 'unsigned int'

Argument 5 here is a bit field declared as:

  unsigned long field : 32;

and if I use a format of '%lu' (what we used so far), I also get a
warning, which wasn't the case with pre-4.x compilers.

Do you know what's wrong here?

Thanks,

  --david
