From: Pavel Machek <pavel@suse.cz>
Date: Sat, 22 Jun 2002 04:44:13 +0000
Subject: Re: [Linux-ia64] Re: [ACPI] [PATCH] random ia64 acpi fixes
Message-Id: <marc-linux-ia64-105590701905725@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590701905684@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590701905684@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Hi!

> > > Won't build on ia64 without this change.
> > 
> > This one is wrong. You should create empty 
> > include/asm/save_state.h instead.
> 
> Feh, introducing save_state.h to begin with was probably a mistake by me.
> 
> (the intention was that save_state.h was a better name than suspend.h since
> that was actually what the stuff in suspend.h did - save CPU state, but in
> retrospect, it was probably not worth doing)

Agreed, I like suspend.h better.
									Pavel
-- 
(about SSSCA) "I don't say this lightly.  However, I really think that the U.S.
no longer is classifiable as a democracy, but rather as a plutocracy." --hpa

