From: David Mosberger <davidm@napali.hpl.hp.com>
Date: Fri, 07 Mar 2003 06:28:46 +0000
Subject: Re: [Linux-ia64] [PATCH] IA32 support without sysctl doesn't work
Message-Id: <marc-linux-ia64-105590709805996@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590709805797@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590709805797@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>>>>> On Thu, 6 Mar 2003 14:55:51 -0700, Bjorn Helgaas <bjorn_helgaas@hp.com> said:

  >> The ia32 subsystem should mirror what's done in kernel/sysctl.c:
  >> when CONFIG_SYSCTL isn't defined, there should be a dummy
  >> sys32_sysctl().  That way, the number of #ifdefs is localized to
  >> one file.

  Bjorn> I applied the following patch to 2.4:

I did the same for 2.5.

Thanks,

	--david

