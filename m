From: David Mosberger <davidm@napali.hpl.hp.com>
Date: Fri, 17 Jan 2003 15:57:50 +0000
Subject: Re: [Linux-ia64] LTT on IA64
Message-Id: <marc-linux-ia64-105590709805712@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590709805711@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590709805711@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>>>>> On Fri, 17 Jan 2003 14:48:13 +0100, Philippe Couvee <PHILIPPE.COUVEE@BULL.NET> said:

  Philippe> However, I need help to implement the tracing of syscall
  Philippe> and traps... basically, I have to call a C function which
  Philippe> will record the syscall number and the user address from
  Philippe> which is issued the call :

Take a look at entry.S:ia64_trace_syscall().  That should get you very
close.

	--david

