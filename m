From: David Mosberger <davidm@napali.hpl.hp.com>
Date: Wed, 15 Oct 2003 06:21:09 +0000
Subject: Re: IA64 ino_t incorrectly sized?
Message-Id: <marc-linux-ia64-106619888120735@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-106378281914262@msgid-missing>
In-Reply-To: <marc-linux-ia64-106378281914262@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>>>>> On Wed, 15 Oct 2003 16:06:02 +1000, Nathan Scott <nathans@sgi.com> said:

  Nathan> It turns out that neither is a problem for us in practice.

Sounds find to me, then.  Except, I'd replace #ifdef __ia64__ with
#ifdef CONFIG_IA64, so you're relying (less) on compiler magic.

	--david
