From: David Mosberger <davidm@napali.hpl.hp.com>
Date: Thu, 02 Jan 2003 21:27:00 +0000
Subject: Re: [Linux-ia64] kernel update (relative to 2.5.52)
Message-Id: <marc-linux-ia64-105590709805632@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590678205111@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590678205111@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>>>>> On Thu, 26 Dec 2002 15:07:11 +0900, Kimio Suganuma <k-suganuma@mvj.biglobe.ne.jp> said:

  Kimio> Hi David,
  Kimio> Please apply this patch for discontigmem.
  Kimio> I made sure NUMA kernel worked fine with the patch
  Kimio> on 16way Itanium machine.

The patch didn't apply because of whitespace issues and because it
wasn't relative to the parent of the top-level directory.  I applied
it by hand now, but in the future, please try to submit proper patches
(if you mailer does the munging, you can send patches as a MIME
attachement).

Thanks,

	--david

