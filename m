From: David Mosberger <davidm@napali.hpl.hp.com>
Date: Fri, 16 Jan 2004 19:18:57 +0000
Subject: Re: shared memory segment size alignment
Message-Id: <16392.14625.163460.993083@napali.hpl.hp.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20040116183111.96883.qmail@web60002.mail.yahoo.com>
In-Reply-To: <20040116183111.96883.qmail@web60002.mail.yahoo.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>>>>> On Fri, 16 Jan 2004 10:31:11 -0800 (PST), umut aymakoglu <umutaymak@yahoo.com> said:

  umut> Hi - In some kernel versions the SHMLBA is defined as
  umut> 1MB(1024*1024) and in some as 16K. What would be the
  umut> difference between aligning the shared memory segment size on
  umut> 1MB versus 16K before calling shmget()? Would there be any
  umut> performance gain/lose? We are aligning the segment address on
  umut> 1MB.

The ia64 architecture allows CPUs to have a performance penalty when
there is virtual aliasing below a 1MB boundary.  So if you don't align
to 1MB, it _could_ run slower.  No existing processor models do that,
but future models might.

	--david
