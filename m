From: David Mosberger <davidm@napali.hpl.hp.com>
Date: Fri, 28 May 2004 22:14:54 +0000
Subject: Re: lib64 in fedora glibc
Message-Id: <16567.47582.153249.521155@napali.hpl.hp.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20040528214105.GK9115@mustard.zk3.dec.com>
In-Reply-To: <20040528214105.GK9115@mustard.zk3.dec.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>>>>> On Fri, 28 May 2004 17:41:05 -0400, Aron Griffis <aron@HP.COM> said:

  Aron> These snippets from the current fedora glibc.spec look suspicious to
  Aron> me.. I was under the impression that ia64 would use /lib for 64-bit
  Aron> and /lib32 for 32-bit (or something like that), but it looks like RH
  Aron> is preparing to transition to lib64.

I'm no Fedora expert but here it says:

  Aron> %changelog:
  Aron> * Thu May 20 2004 Jakub Jelinek <jakub@redhat.com> 2.3.3-29
  Aron> - use lib64 instead of lib on ia64 if %%{_lib} is defined to lib64

So I guess the question is what would make %%{_lib} be defined as lib64.

IMHO, it would be a bad mistake to create such a disruption.

	--david
