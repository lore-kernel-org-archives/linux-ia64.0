From: David Mosberger <davidm@hpl.hp.com>
Date: Thu, 02 Aug 2001 01:29:16 +0000
Subject: Re: [Linux-ia64] Tracing the execution path
Message-Id: <marc-linux-ia64-105590693005989@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590693005979@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590693005979@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>>>>> On Wed, 1 Aug 2001 11:59:40 -0700 (PDT), Krishna Kanth Sistla <krishnakanths@yahoo.com> said:

  Krishna> Hi all, I am doing some benchmarking runs on a Softsur
  Krishna> running linux. I am interested in obtaining the actual
  Krishna> execution trace of a user level code. Is there some tool in
  Krishna> linux that can let me do this?. Some tool that

  Krishna> can print out the intruction execution trace of any user
  Krishna> level program. Any help will be greatly appreciated.

The HP Ski simulator can do that.  See http://software.hp.com/ia64linux/

The other thing you could do is use the utrace program that I posted
to this list a while ago.  It can do both taken-branch trap based
tracing and single-step trap based tracing.

	--david

