import React, { useEffect, useState } from 'react'
import styles from '../styles/Home.module.css'
import { ethers } from "ethers";

const ConnectWallet = () => {
    const [isConnected, setIsConnected] = useState(false);

    useEffect(() => {
        if (ethereum.selectedAddress) setIsConnected(true);
    });

    async function connect() {
        if (typeof window.ethereum !== "undefined") {
            try {
                const acc = await ethereum.request({ method: "eth_requestAccounts" });
                setIsConnected(true);
            } catch (e) {
                console.log(e);
            }
        } else {
            setIsConnected(false);
        }
    }

    return (
        <main>
            {isConnected
                ? <button className={styles.card} disabled>Connected</button>
                : <button className={styles.card} onClick={() => connect()}>Connect Wallet</button>
            }
        </main>
    )
}

export default ConnectWallet