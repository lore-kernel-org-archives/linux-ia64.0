From: David Mosberger <davidm@napali.hpl.hp.com>
Date: Mon, 28 Oct 2002 07:31:41 +0000
Subject: Re: [Linux-ia64] build a bootable kernel
Message-Id: <marc-linux-ia64-105590709805274@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590709805272@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590709805272@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>>>>> On Mon, 28 Oct 2002 14:49:11 +0800, "dai yiyang" <daiyiyang@hotmail.com> said:

  dai> Hi : I have build a 2.5.39 kernel under redhat 7.2 use "make
  dai> vmlinux" , the output file vmlinux is 55M!  and seems cannot be
  dai> loaded by elilo .  Per my check the original kernel file
  dai> default installed on the system is only 1M , I think it should
  dai> been compressed .  Anybody can provide me the right step to
  dai> build a bootable kernel under ia64 ?

	make compressed

will build you a stripped & compressed kernel in vmlinux.gz.

	--david

