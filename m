From: David Lombard <david.lombard@mscsoftware.com>
Date: Wed, 10 May 2000 20:57:27 +0000
Subject: Re: [Linux-ia64] ksh for ia64
Message-Id: <marc-linux-ia64-105590678205079@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590678205077@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590678205077@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

roneng@ca.ibm.com wrote:
> 
> Hi,
> 
> Does anyone know if there is an ia64 pdksh rpm available anywhere, Or
> has been able to compile, and run pdksh success fully?
> 

It's on my to-do list as ksh is needed for some of our products.

For interaction, bash may be sufficient -- it has been for me, a
long-time, expert, ksh user.  If you prefer vi editing, put "set
editing-mode vi" in your ~/.inputrc file.  While bash isn't KSH-88
conformant (pdksh isn't either), it does have many features that make it
quite acceptable.

For my scripting, bash's typeset command is fairly limited and print
doesn't exist; but other features, such as command substition, e.g., $(
... ), substrings of variables, e.g., ${0##*/}, and compound if, e.g.,
[[ ... ]], work as expected.

-- 
David N. Lombard
MSC.Software


