From: Keith Owens <kaos@ocs.com.au>
Date: Fri, 07 Dec 2001 23:20:10 +0000
Subject: [Linux-ia64] Linux 2.4.17-pre6 drm-4.0
Message-Id: <marc-linux-ia64-105590698805653@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Fri, 7 Dec 2001 19:38:23 -0200 (BRST), 
Marcelo Tosatti <marcelo@conectiva.com.br> wrote:
>pre6:
>- direct render for some SiS cards		(Torsten Duwe/Alan Cox)

IA64 is still using the drm-4.0 code, as are the (possibly obsolete)
-ac kernels.  The drm 4.0 makefiles are a pain in the neck and I want
to get rid of them asap.  The SiS direct render is only for drm 4.1 so
now is a good time to question if 4.0 is still required.

How long do people plan to keep drm 4.0 code in their versions of the
kernel?


