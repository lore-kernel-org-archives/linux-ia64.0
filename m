From: David Mosberger <davidm@hpl.hp.com>
Date: Fri, 07 Dec 2001 23:38:23 +0000
Subject: Re: [Linux-ia64] Linux 2.4.17-pre6 drm-4.0
Message-Id: <marc-linux-ia64-105590698805656@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590698805653@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590698805653@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>>>>> On Sat, 08 Dec 2001 10:20:10 +1100, Keith Owens <kaos@ocs.com.au> said:

  Keith> On Fri, 7 Dec 2001 19:38:23 -0200 (BRST), Marcelo Tosatti
  Keith> <marcelo@conectiva.com.br> wrote:
  >> pre6: - direct render for some SiS cards (Torsten Duwe/Alan Cox)

  Keith> IA64 is still using the drm-4.0 code, as are the (possibly
  Keith> obsolete) -ac kernels.  The drm 4.0 makefiles are a pain in
  Keith> the neck and I want to get rid of them asap.  The SiS direct
  Keith> render is only for drm 4.1 so now is a good time to question
  Keith> if 4.0 is still required.

  Keith> How long do people plan to keep drm 4.0 code in their
  Keith> versions of the kernel?

You mean for 2.5?  I don't think there is a good reason to keep
drm-4.0 there.  For 2.4, we should keep it because there might be
folks out there that rely on it.

	--david

