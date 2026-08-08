const csrfToken = () => document.querySelector("meta[name='csrf-token']")?.content

const post = async (url, body = {}) => {
  const response = await fetch(url, {
    method: "POST",
    credentials: "same-origin",
    headers: {
      "Accept": "application/json",
      "Content-Type": "application/json",
      "X-CSRF-Token": csrfToken()
    },
    body: JSON.stringify(body)
  })

  const payload = await response.json()
  if (!response.ok) throw new Error(payload.error || "The passkey request could not be completed.")
  return payload
}

const bytesFromBase64url = (value) => {
  const padded = value.replace(/-/g, "+").replace(/_/g, "/").padEnd(Math.ceil(value.length / 4) * 4, "=")
  const binary = atob(padded)
  return Uint8Array.from(binary, (character) => character.charCodeAt(0)).buffer
}

const base64urlFromBytes = (buffer) => {
  const bytes = new Uint8Array(buffer)
  let binary = ""
  bytes.forEach((byte) => { binary += String.fromCharCode(byte) })
  return btoa(binary).replace(/\+/g, "-").replace(/\//g, "_").replace(/=+$/, "")
}

const decodeOptions = (options, operation) => {
  const publicKey = { ...options, challenge: bytesFromBase64url(options.challenge) }

  if (operation === "register") {
    publicKey.user = { ...options.user, id: bytesFromBase64url(options.user.id) }
    publicKey.excludeCredentials = (options.excludeCredentials || []).map((credential) => ({
      ...credential, id: bytesFromBase64url(credential.id)
    }))
  } else {
    publicKey.allowCredentials = (options.allowCredentials || []).map((credential) => ({
      ...credential, id: bytesFromBase64url(credential.id)
    }))
  }

  return publicKey
}

const serializeCredential = (credential) => {
  const response = credential.response
  const serialized = {
    id: credential.id,
    rawId: base64urlFromBytes(credential.rawId),
    type: credential.type,
    authenticatorAttachment: credential.authenticatorAttachment,
    clientExtensionResults: credential.getClientExtensionResults(),
    response: {
      clientDataJSON: base64urlFromBytes(response.clientDataJSON)
    }
  }

  if (response.attestationObject) {
    serialized.response.attestationObject = base64urlFromBytes(response.attestationObject)
    serialized.response.transports = response.getTransports ? response.getTransports() : []
  } else {
    serialized.response.authenticatorData = base64urlFromBytes(response.authenticatorData)
    serialized.response.signature = base64urlFromBytes(response.signature)
    serialized.response.userHandle = response.userHandle ? base64urlFromBytes(response.userHandle) : null
  }

  return serialized
}

const beginPasskeyCeremony = async (button) => {
  if (!window.PublicKeyCredential || !navigator.credentials) {
    throw new Error("Passkeys are not available in this browser.")
  }

  const operation = button.dataset.passkeyAction
  const options = await post(button.dataset.optionsUrl)
  const publicKey = decodeOptions(options, operation)
  const credential = operation === "register"
    ? await navigator.credentials.create({ publicKey })
    : await navigator.credentials.get({ publicKey })
  const result = await post(button.dataset.submitUrl, { credential: serializeCredential(credential) })

  if (result.redirect_to) window.location.assign(result.redirect_to)
  else window.alert("Your passkey is ready to use.")
}

document.addEventListener("click", async (event) => {
  const button = event.target.closest("[data-passkey-action]")
  if (!button) return

  event.preventDefault()
  button.disabled = true
  try {
    await beginPasskeyCeremony(button)
  } catch (error) {
    window.alert(error.message)
  } finally {
    button.disabled = false
  }
})
