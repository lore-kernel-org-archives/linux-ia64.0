From: law@redhat.com
Date: Thu, 03 Jan 2002 17:11:20 +0000
Subject: [Linux-ia64] Re: is casting of function descriptor assignments for ia64 ONLY a
Message-Id: <marc-linux-ia64-105590698805736@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590698805734@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590698805734@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

  > Not just ia64, powerpc 64 as well.  You are assuming that all pointers
  > are the same format when that is not guaranteed by the C standard.  On
  > most architectures they are the same, you can convert a function
  > pointer to a void pointer and back again but it is not defined
  > behaviour.
  > 
  > On IA64 and PPC64 the function pointer does not reference the function
  > itself, instead it points to a function descriptor.  The function
  > descriptor contains a pointer to the function code plus additional data
  > such as a pointer to the global data to be used when the function is
  > called.  This is mandated by the architecture software ABI.
Also true for HPPA targets.
jeff


