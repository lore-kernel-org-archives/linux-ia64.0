From: David Mosberger <davidm@napali.hpl.hp.com>
Date: Thu, 07 Aug 2003 04:53:33 +0000
Subject: Re: 2.4 PATCH: gcc 3.3 support
Message-Id: <marc-linux-ia64-106023204315087@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-106018469231198@msgid-missing>
In-Reply-To: <marc-linux-ia64-106018469231198@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>>>>> On Wed, 6 Aug 2003 19:51:19 -0700, "H. J. Lu" <hjl@lucon.org> said:

  H> On Wed, Aug 06, 2003 at 09:59:34AM -0600, Bjorn Helgaas wrote:
  >> On Wednesday 06 August 2003 9:44 am, H. J. Lu wrote: > This is
  >> the patch backed ported from 2.6 kernel. However, I got

  >> > # modprobe xor > raid5: measuring checksumming speed > ia64 :
  >> 81.920 MB/sec

  H> This number was under heavy load. I got

  H> Aug 6 09:03:38 gnu-2 kernel: raid5: measuring checksumming speed
  H> Aug 6 09:03:38 gnu-2 kernel: ia64 : 98.304 MB/sec Aug 6 09:03:38
  H> gnu-2 kernel: raid5: using function: ia64 (98.304 MB/sec)

  H> with 2.4 kernel when machine was idle.

I can't reproduce this.  With 2.6.0-test2 on a zx6000, I get:

raid5: measuring checksumming speed
   ia64      :  2080.768 MB/sec
raid5: using function: ia64 (2080.768 MB/sec)

	--david
