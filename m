From: Keith Owens <kaos@ocs.com.au>
Date: Wed, 15 Aug 2001 00:22:43 +0000
Subject: Re: [Linux-ia64] kernel update (relative to 2.4.8)
Message-Id: <marc-linux-ia64-105590698805080@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590678205111@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590678205111@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Tue, 14 Aug 2001 08:48:11 -0700, 
David Mosberger <davidm@hpl.hp.com> wrote:
>>>>>> On Tue, 14 Aug 2001 18:51:32 +1000, Keith Owens <kaos@ocs.com.au> said:
>
>  Keith> If you are going to keep both DRM 4.0 and 4.1, please do it
>  Keith> the same way that Alan Cox did, to reduce the number of
>  Keith> solutions to this "problem".  The -ac kernels have, in
>  Keith> drivers/char/Config.in
>
>At the moment, only 4.0 is there.  Perhaps I should include both once
>4.1 works for IA64.

I recommend doing it now.  The ia64 patch is much larger that it need
be because you delete the 4.1 code as well as adding back the 4.0 code.
If you just add 4.0 as drm-old (the same way as AC) then you get a
smaller patch footprint.  Not to mention making it easier to track
Linus's and AC's kernels.

The only downside is that ia64 users have to select drm-old instead of
drm, but that is already true for a lot of non-ia64 users.


