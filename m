From: Venkatesh Ramamurthy <Venkateshr@ami.com>
Date: Mon, 21 Feb 2000 20:35:21 +0000
Subject: RE: [Linux-ia64] Cant compile compiler
Message-Id: <marc-linux-ia64-105590678204949@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590678204946@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590678204946@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Any one to help me ...... 
All i wanted was to compile the cross-compiler ...... 
Did anyone attend IDF , where a special mention was given about those 2
files stdlib.h and unistd.h .....
Can anyone mail me the binary for the entire cross compiler ..... it would
be very nice if it could be done ......
As a driver developer , i feel it would be nice if didnt have to know the
intricacies of compiler development ..... Is this is all about Open Source
concept where one is given source code ... but doesnt compile ... sigh (
well it maybe my fault ...) .... 

Help will be appreciated ....
TIA
Venkatesh



On Monday, February 21, 2000 3:27 PM, Uros Prestor
[SMTP:uros@turbolinux.com] wrote:
| Venkatesh Ramamurthy <Venkateshr@ami.com> said: 
| > | You need to have IA-64 include files and IA-64 libraries to bootstrap
| > | the compiler.  Install /usr/include and /usr/lib from the Trillian CD
| > 
| > 
| > Did you mean /usr/src/linux/include and /usr/src/linux/lib , since there
is
| > no headers and libraries inside /usr/include and /usr/lib in Trillian
CD.
| 
| Oops -- I forgot that the Trillian CD shipped without /usr/include
| and /usr/lib.  You need these to build a compiler the way I built it.
| 
| Jim Wilson (the Cygnus gcc guy) said something about posting
| instructions on how to build the native IA-64 toolchain.
| He knows more about how much can be released and how to
| build the toolchain with a cross-compiler.  I don't know what
| needs to be done if you don't have /usr/lib and /usr/include.
| 
| Uros


