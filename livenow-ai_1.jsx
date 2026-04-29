import { useState, useEffect, useRef } from "react";

const STEPS = ["home", "input", "analyze", "reframe", "action", "complete"];

// ── AI call ──────────────────────────────────────────────────────────────────
async function analyzeThought(thought) {
  const prompt = `You are a calm, compassionate CBT-based mental health assistant inside an app called LiveNow that helps people with overthinking.

The user has shared this thought: "${thought}"

Respond ONLY with a valid JSON object (no markdown, no explanation, nothing else) in this exact shape:

{
  "analysis": [
    { "label": "short label (4-6 words)", "sub": "one supportive sentence explaining why" },
    { "label": "short label (4-6 words)", "sub": "one supportive sentence explaining why" }
  ],
  "evidence": [
    { "q": "do you have proof?", "a": "no / maybe / yes" },
    { "q": "is there another explanation?", "a": "yes / maybe / no" },
    { "q": "how important is this in 1 week?", "a": "very low / low / medium / high" }
  ],
  "reframes": [
    "Short, grounded reframe sentence 1.",
    "Short, grounded reframe sentence 2.",
    "Short, grounded reframe sentence 3.",
    "Short, grounded reframe sentence 4."
  ],
  "actions": [
    { "icon": "🚶", "label": "specific action tailored to the thought" },
    { "icon": "✍️", "label": "specific action tailored to the thought" },
    { "icon": "🌬", "label": "specific action tailored to the thought" },
    { "icon": "💬", "label": "specific action tailored to the thought" },
    { "icon": "✦",  "label": "specific action tailored to the thought" }
  ],
  "insight": "One short, kind sentence (max 12 words) that captures the core of what's happening emotionally."
}

Make ALL content directly relevant to the specific thought shared. Be warm, grounded, non-clinical.`;

  const res = await fetch("https://api.anthropic.com/v1/messages", {
    method: "POST",
    headers: { "Content-Type": "application/json" },
    body: JSON.stringify({
      model: "claude-sonnet-4-20250514",
      max_tokens: 1000,
      messages: [{ role: "user", content: prompt }],
    }),
  });

  const data = await res.json();
  const text = data.content.map(b => b.text || "").join("");
  const clean = text.replace(/```json|```/g, "").trim();
  return JSON.parse(clean);
}

// ── Shared components ─────────────────────────────────────────────────────────
function ProgressBar({ step }) {
  const steps = ["input", "analyze", "reframe", "action"];
  const idx = steps.indexOf(step);
  if (idx === -1) return null;
  return (
    <div style={{ display: "flex", alignItems: "center", gap: 8, flex: 1 }}>
      <span style={{ fontSize: 12, color: "#aaa", whiteSpace: "nowrap" }}>{idx + 1} of 4</span>
      <div style={{ flex: 1, height: 3, background: "#f0f0f0", borderRadius: 2 }}>
        <div style={{ width: `${((idx + 1) / 4) * 100}%`, height: "100%", background: "#FF6B2B", borderRadius: 2, transition: "width 0.4s ease" }} />
      </div>
    </div>
  );
}

function OrangeBtn({ onClick, children, disabled, style = {} }) {
  return (
    <button onClick={onClick} disabled={disabled} style={{
      width: "100%", padding: "18px", borderRadius: 50, border: "none",
      background: disabled ? "#f0f0f0" : "linear-gradient(135deg, #FF6B2B, #FF8C00)",
      color: disabled ? "#bbb" : "#fff",
      fontSize: 16, fontWeight: 700, cursor: disabled ? "not-allowed" : "pointer",
      transition: "all 0.2s", ...style,
    }}>{children}</button>
  );
}

function BackRow({ onBack, step }) {
  return (
    <div style={{ display: "flex", alignItems: "center", gap: 12, marginBottom: 16 }}>
      <button onClick={onBack} style={{ background: "none", border: "none", fontSize: 20, cursor: "pointer", color: "#555", padding: 0, flexShrink: 0 }}>←</button>
      <ProgressBar step={step} />
    </div>
  );
}

function ThoughtBubble({ thought }) {
  return (
    <div style={{ background: "#fff9f6", borderRadius: 16, padding: "12px 16px", marginBottom: 16, border: "1px solid #ffe8dc" }}>
      <p style={{ fontSize: 13, color: "#FF6B2B", margin: 0, fontStyle: "italic" }}>"{thought}"</p>
    </div>
  );
}

function Spinner() {
  const [dots, setDots] = useState(".");
  useEffect(() => {
    const t = setInterval(() => setDots(d => d.length >= 3 ? "." : d + "."), 500);
    return () => clearInterval(t);
  }, []);
  return (
    <div style={{ flex: 1, display: "flex", flexDirection: "column", alignItems: "center", justifyContent: "center", gap: 16 }}>
      <div style={{
        width: 48, height: 48, borderRadius: "50%",
        border: "3px solid #f0f0f0", borderTopColor: "#FF6B2B",
        animation: "spin 0.8s linear infinite",
      }} />
      <style>{`@keyframes spin { to { transform: rotate(360deg); } }`}</style>
      <p style={{ color: "#aaa", fontSize: 14 }}>analyzing your thought{dots}</p>
    </div>
  );
}

// ── Screens ───────────────────────────────────────────────────────────────────
function HomeScreen({ onStart, recentThoughts }) {
  return (
    <div style={{ display: "flex", flexDirection: "column", alignItems: "center", height: "100%", padding: "40px 24px 24px" }}>
      <div style={{ alignSelf: "stretch", display: "flex", justifyContent: "space-between", marginBottom: 32 }}>
        <span style={{ fontSize: 20 }}>☰</span>
        <span style={{ fontSize: 20 }}>👤</span>
      </div>
      <div style={{ textAlign: "center", marginBottom: 40 }}>
        <h1 style={{ fontSize: 36, fontFamily: "'Georgia', serif", fontWeight: 900, lineHeight: 1.1, margin: 0, color: "#111" }}>
          get out of<br /><span style={{ color: "#FF6B2B" }}>your head.</span>
        </h1>
        <p style={{ fontSize: 13, color: "#aaa", marginTop: 10 }}>you don't need to figure everything out right now.</p>
      </div>
      <button onClick={onStart} style={{
        width: 140, height: 140, borderRadius: "50%",
        background: "linear-gradient(135deg, #FF6B2B, #FF8C00)",
        border: "none", cursor: "pointer", display: "flex", flexDirection: "column",
        alignItems: "center", justifyContent: "center",
        boxShadow: "0 12px 40px rgba(255,107,43,0.4)", marginBottom: 40,
        transition: "transform 0.15s ease, box-shadow 0.15s ease",
      }}
        onMouseEnter={e => { e.currentTarget.style.transform = "scale(1.05)"; }}
        onMouseLeave={e => { e.currentTarget.style.transform = "scale(1)"; }}
      >
        <span style={{ fontSize: 24, marginBottom: 4 }}>〰</span>
        <span style={{ color: "#fff", fontWeight: 800, fontSize: 18, letterSpacing: 1 }}>RESET</span>
        <span style={{ color: "rgba(255,255,255,0.8)", fontSize: 11, marginTop: 2 }}>clear your mind</span>
      </button>

      {recentThoughts.length > 0 && (
        <div style={{ alignSelf: "stretch" }}>
          <div style={{ display: "flex", justifyContent: "space-between", marginBottom: 12 }}>
            <span style={{ fontSize: 12, color: "#888" }}>recent thoughts</span>
            <span style={{ fontSize: 12, color: "#FF6B2B" }}>see all ›</span>
          </div>
          {recentThoughts.slice(-3).reverse().map((t, i) => (
            <div key={i} style={{ display: "flex", alignItems: "center", gap: 10, padding: "10px 0", borderBottom: "1px solid #f5f5f5" }}>
              <span style={{ width: 6, height: 6, borderRadius: "50%", background: "#FF6B2B", flexShrink: 0 }} />
              <span style={{ fontSize: 13, color: "#333", flex: 1 }}>{t.text}</span>
              <span style={{ fontSize: 11, color: "#bbb" }}>just now</span>
            </div>
          ))}
        </div>
      )}
      <p style={{ fontSize: 11, color: "#bbb", marginTop: "auto", paddingTop: 16 }}>
        most thoughts <span style={{ color: "#FF6B2B" }}>are not facts.</span>
      </p>
    </div>
  );
}

function InputScreen({ onNext, onBack, thought, setThought, loading }) {
  const examples = ["they think I'm weird", "I said something stupid", "I'm not good enough"];
  return (
    <div style={{ display: "flex", flexDirection: "column", height: "100%", padding: "24px 24px 32px" }}>
      <BackRow onBack={onBack} step="input" />
      <h2 style={{ fontSize: 28, fontFamily: "'Georgia', serif", fontWeight: 700, margin: "20px 0 6px", color: "#111", lineHeight: 1.2 }}>
        what's on<br />your mind?
      </h2>
      <p style={{ fontSize: 13, color: "#aaa", marginBottom: 24 }}>write freely. no filter.</p>
      <textarea
        value={thought}
        onChange={e => setThought(e.target.value)}
        placeholder="type your thought..."
        style={{
          flex: 1, border: "1.5px solid #eee", borderRadius: 16, padding: "16px", fontSize: 15,
          fontFamily: "inherit", resize: "none", outline: "none", color: "#333", lineHeight: 1.6,
        }}
        onFocus={e => e.target.style.borderColor = "#FF6B2B"}
        onBlur={e => e.target.style.borderColor = "#eee"}
      />
      <div style={{ marginTop: 16, marginBottom: 24 }}>
        <p style={{ fontSize: 11, color: "#bbb", marginBottom: 10 }}>examples</p>
        {examples.map((ex, i) => (
          <button key={i} onClick={() => setThought(ex)}
            style={{ display: "block", background: "none", border: "none", color: "#888", fontSize: 13, cursor: "pointer", padding: "4px 0", textAlign: "left" }}>
            {ex}
          </button>
        ))}
      </div>
      <OrangeBtn onClick={onNext} disabled={!thought.trim() || loading}>
        {loading ? "analyzing..." : "analyze"}
      </OrangeBtn>
    </div>
  );
}

function AnalyzeScreen({ onNext, onBack, thought, aiData }) {
  const [revealed, setRevealed] = useState(0);
  const total = (aiData?.analysis?.length || 0) + 1;

  useEffect(() => {
    if (revealed < total) {
      const t = setTimeout(() => setRevealed(r => r + 1), 450);
      return () => clearTimeout(t);
    }
  }, [revealed, total]);

  if (!aiData) return <Spinner />;

  return (
    <div style={{ display: "flex", flexDirection: "column", height: "100%", padding: "24px 24px 32px" }}>
      <BackRow onBack={onBack} step="analyze" />
      <h2 style={{ fontSize: 28, fontFamily: "'Georgia', serif", fontWeight: 700, margin: "20px 0 6px", color: "#111" }}>
        let's analyze<br />this thought
      </h2>
      <p style={{ fontSize: 13, color: "#aaa", marginBottom: 8 }}>this helps you see clearly.</p>
      <ThoughtBubble thought={thought} />

      <div style={{ flex: 1, overflowY: "auto" }}>
        {aiData.analysis.map((item, i) => (
          <div key={i} style={{
            display: "flex", justifyContent: "space-between", alignItems: "center",
            padding: "14px 0", borderBottom: "1px solid #f5f5f5",
            opacity: revealed > i ? 1 : 0,
            transform: revealed > i ? "translateY(0)" : "translateY(8px)",
            transition: "all 0.4s ease",
          }}>
            <div style={{ flex: 1, paddingRight: 12 }}>
              <p style={{ margin: 0, fontWeight: 600, fontSize: 14, color: "#111" }}>{item.label}</p>
              <p style={{ margin: 0, fontSize: 12, color: "#aaa", marginTop: 2 }}>{item.sub}</p>
            </div>
            <span style={{ fontSize: 24 }}>🧠</span>
          </div>
        ))}

        <div style={{
          marginTop: 16, padding: "16px", background: "#f9f9f9", borderRadius: 16,
          opacity: revealed >= aiData.analysis.length ? 1 : 0,
          transition: "opacity 0.5s ease",
        }}>
          <p style={{ margin: "0 0 12px", fontWeight: 700, fontSize: 13, color: "#555" }}>evidence check</p>
          {aiData.evidence.map((item, i) => (
            <div key={i} style={{ display: "flex", justifyContent: "space-between", marginBottom: 8 }}>
              <span style={{ fontSize: 13, color: "#777" }}>{item.q}</span>
              <span style={{ fontSize: 13, color: "#FF6B2B", fontWeight: 600 }}>{item.a}</span>
            </div>
          ))}
        </div>

        {aiData.insight && (
          <div style={{
            marginTop: 12, padding: "14px 16px", background: "#fff9f6", borderRadius: 16,
            border: "1px solid #ffe8dc",
            opacity: revealed >= total ? 1 : 0, transition: "opacity 0.5s ease 0.3s",
          }}>
            <p style={{ margin: 0, fontSize: 13, color: "#FF6B2B", fontStyle: "italic" }}>💡 {aiData.insight}</p>
          </div>
        )}
      </div>

      <OrangeBtn onClick={onNext} style={{ marginTop: 16 }}>continue</OrangeBtn>
    </div>
  );
}

function ReframeScreen({ onNext, onBack, thought, aiData }) {
  const [activeIdx, setActiveIdx] = useState(0);
  if (!aiData) return <Spinner />;

  return (
    <div style={{ display: "flex", flexDirection: "column", height: "100%", padding: "24px 24px 32px" }}>
      <BackRow onBack={onBack} step="reframe" />
      <h2 style={{ fontSize: 28, fontFamily: "'Georgia', serif", fontWeight: 700, margin: "20px 0 6px", color: "#111" }}>
        let's reframe<br />this
      </h2>
      <p style={{ fontSize: 13, color: "#aaa", marginBottom: 24 }}>a more realistic view</p>

      <div style={{ flex: 1, overflowY: "auto" }}>
        {aiData.reframes.map((line, i) => (
          <div key={i} onClick={() => setActiveIdx(i)} style={{
            padding: "16px 20px", marginBottom: 12, borderRadius: 16, cursor: "pointer",
            background: activeIdx === i ? "#fff9f6" : "#fafafa",
            border: activeIdx === i ? "2px solid #FF6B2B" : "2px solid transparent",
            transition: "all 0.2s",
          }}>
            <p style={{ margin: 0, fontSize: 15, fontWeight: activeIdx === i ? 700 : 400, color: activeIdx === i ? "#111" : "#777", lineHeight: 1.4 }}>
              {line}
            </p>
          </div>
        ))}

        <div style={{ background: "#f9f9f9", borderRadius: 16, padding: "16px", marginTop: 8, display: "flex", gap: 12 }}>
          <span style={{ fontSize: 24, flexShrink: 0 }}>🧠</span>
          <p style={{ margin: 0, fontSize: 13, color: "#555", lineHeight: 1.6 }}>
            <strong>"{thought}"</strong> — {aiData.reframes[activeIdx]}
          </p>
        </div>
      </div>

      <OrangeBtn onClick={onNext} style={{ marginTop: 16 }}>continue</OrangeBtn>
    </div>
  );
}

function ActionScreen({ onNext, onBack, aiData }) {
  const [selected, setSelected] = useState(0);
  if (!aiData) return <Spinner />;

  return (
    <div style={{ display: "flex", flexDirection: "column", height: "100%", padding: "24px 24px 32px" }}>
      <BackRow onBack={onBack} step="action" />
      <h2 style={{ fontSize: 26, fontFamily: "'Georgia', serif", fontWeight: 700, margin: "20px 0 6px", color: "#111", lineHeight: 1.2 }}>
        what's one small<br />step you can<br />take now?
      </h2>
      <p style={{ fontSize: 13, color: "#aaa", marginBottom: 24 }}>shift your focus</p>

      <div style={{ flex: 1, overflowY: "auto" }}>
        {aiData.actions.map((opt, i) => (
          <div key={i} onClick={() => setSelected(i)} style={{
            display: "flex", justifyContent: "space-between", alignItems: "center",
            padding: "16px 20px", marginBottom: 10, borderRadius: 16, cursor: "pointer",
            background: selected === i ? "#fff9f6" : "#fafafa",
            border: selected === i ? "2px solid #FF6B2B" : "2px solid transparent",
            transition: "all 0.2s",
          }}>
            <div style={{ display: "flex", alignItems: "center", gap: 12 }}>
              <span style={{ fontSize: 18 }}>{opt.icon}</span>
              <span style={{ fontSize: 14, color: "#333" }}>{opt.label}</span>
            </div>
            {selected === i && (
              <div style={{ width: 24, height: 24, borderRadius: "50%", background: "#FF6B2B", display: "flex", alignItems: "center", justifyContent: "center", flexShrink: 0 }}>
                <span style={{ color: "#fff", fontSize: 14 }}>✓</span>
              </div>
            )}
          </div>
        ))}
      </div>

      <OrangeBtn onClick={onNext} style={{ marginTop: 8, marginBottom: 8 }}>finish</OrangeBtn>
      <button onClick={onNext} style={{ width: "100%", background: "none", border: "none", color: "#bbb", fontSize: 13, cursor: "pointer", padding: "8px" }}>
        skip for now
      </button>
    </div>
  );
}

function CompleteScreen({ onReset, thought, aiData }) {
  const [scale, setScale] = useState(0);
  useEffect(() => { setTimeout(() => setScale(1), 100); }, []);

  return (
    <div style={{ display: "flex", flexDirection: "column", alignItems: "center", height: "100%", padding: "40px 24px 32px", textAlign: "center" }}>
      <div style={{ alignSelf: "flex-end", marginBottom: 32 }}>
        <button onClick={onReset} style={{ background: "none", border: "none", fontSize: 20, cursor: "pointer", color: "#ccc" }}>✕</button>
      </div>

      <div style={{ position: "relative", marginBottom: 40, marginTop: 20 }}>
        {[...Array(6)].map((_, i) => (
          <div key={i} style={{
            position: "absolute", width: 6, height: 6, borderRadius: "50%", background: "#FF6B2B",
            top: `${Math.sin(i * 60 * Math.PI / 180) * 80}px`,
            left: `${Math.cos(i * 60 * Math.PI / 180) * 80 + 55}px`,
            opacity: scale, transition: `opacity 0.5s ease ${i * 0.1}s`,
          }} />
        ))}
        <div style={{
          width: 110, height: 110, borderRadius: "50%",
          background: "linear-gradient(135deg, #FF6B2B, #FF8C00)",
          display: "flex", alignItems: "center", justifyContent: "center",
          transform: `scale(${scale})`, transition: "transform 0.5s cubic-bezier(0.34,1.56,0.64,1)",
          boxShadow: "0 16px 50px rgba(255,107,43,0.35)",
        }}>
          <span style={{ fontSize: 40, color: "#fff" }}>✓</span>
        </div>
      </div>

      <h2 style={{ fontSize: 30, fontFamily: "'Georgia', serif", fontWeight: 800, margin: "0 0 8px", color: "#111" }}>reset complete</h2>
      <p style={{ fontSize: 14, color: "#aaa", marginBottom: 24 }}>you're back in control.</p>

      <div style={{ background: "#f9f9f9", borderRadius: 20, padding: "20px", marginBottom: 16, width: "100%", maxWidth: 280 }}>
        <p style={{ margin: "0 0 8px", fontSize: 13, color: "#555", fontStyle: "italic" }}>"{thought}"</p>
        {aiData?.insight && <p style={{ margin: "0 0 8px", fontSize: 12, color: "#FF6B2B" }}>💡 {aiData.insight}</p>}
        <p style={{ margin: 0, fontSize: 12, color: "#aaa" }}>you challenged this thought and chose action. ✦</p>
      </div>

      <OrangeBtn onClick={onReset} style={{ maxWidth: 280, marginBottom: 16, boxShadow: "0 8px 30px rgba(255,107,43,0.3)" }}>
        new reset
      </OrangeBtn>
      <span style={{ fontSize: 13, color: "#FF6B2B", cursor: "pointer" }}>view history</span>

      <div style={{ display: "flex", gap: 32, marginTop: "auto", paddingTop: 24 }}>
        {[["🏠", "home"], ["🕐", "history"], ["📊", "insights"], ["👤", "profile"]].map(([icon, label]) => (
          <div key={label} style={{ display: "flex", flexDirection: "column", alignItems: "center", gap: 4, cursor: "pointer" }}>
            <span style={{ fontSize: 20 }}>{icon}</span>
            <span style={{ fontSize: 10, color: label === "home" ? "#FF6B2B" : "#bbb" }}>{label}</span>
          </div>
        ))}
      </div>
    </div>
  );
}

// ── Root ──────────────────────────────────────────────────────────────────────
export default function LiveNowApp() {
  const [step, setStep] = useState("home");
  const [thought, setThought] = useState("");
  const [aiData, setAiData] = useState(null);
  const [loading, setLoading] = useState(false);
  const [error, setError] = useState(null);
  const [history, setHistory] = useState([]);

  const handleAnalyze = async () => {
    if (!thought.trim()) return;
    setLoading(true);
    setError(null);
    try {
      const data = await analyzeThought(thought);
      setAiData(data);
      setStep("analyze");
    } catch (e) {
      setError("Something went wrong. Please try again.");
    } finally {
      setLoading(false);
    }
  };

  const next = () => {
    const idx = STEPS.indexOf(step);
    if (idx < STEPS.length - 1) setStep(STEPS[idx + 1]);
  };

  const back = () => {
    const idx = STEPS.indexOf(step);
    if (idx > 0) setStep(STEPS[idx - 1]);
  };

  const reset = () => {
    if (thought.trim()) setHistory(h => [...h, { text: thought }]);
    setThought("");
    setAiData(null);
    setStep("home");
  };

  const screenMap = {
    home: <HomeScreen onStart={() => setStep("input")} recentThoughts={history} />,
    input: (
      <InputScreen
        onNext={handleAnalyze}
        onBack={() => setStep("home")}
        thought={thought}
        setThought={setThought}
        loading={loading}
      />
    ),
    analyze: <AnalyzeScreen onNext={next} onBack={back} thought={thought} aiData={aiData} />,
    reframe: <ReframeScreen onNext={next} onBack={back} thought={thought} aiData={aiData} />,
    action: <ActionScreen onNext={next} onBack={back} aiData={aiData} />,
    complete: <CompleteScreen onReset={reset} thought={thought} aiData={aiData} />,
  };

  return (
    <div style={{ display: "flex", alignItems: "center", justifyContent: "center", minHeight: "100vh", background: "#f0ece8", fontFamily: "'Helvetica Neue', Helvetica, sans-serif" }}>
      <div style={{
        width: 375, height: 780, background: "#fff", borderRadius: 44,
        overflow: "hidden", position: "relative",
        boxShadow: "0 40px 100px rgba(0,0,0,0.18), 0 0 0 8px #111, 0 0 0 10px #333",
      }}>
        <div style={{ display: "flex", justifyContent: "space-between", padding: "14px 24px 0", fontSize: 12, fontWeight: 600, color: "#111" }}>
          <span>9:41</span>
          <span>▋▋▋ 📶 🔋</span>
        </div>
        <div style={{ height: "calc(100% - 40px)", overflowY: "auto" }}>
          {error ? (
            <div style={{ padding: 32, textAlign: "center" }}>
              <p style={{ color: "#FF6B2B", marginBottom: 16 }}>{error}</p>
              <OrangeBtn onClick={() => { setError(null); setStep("input"); }}>try again</OrangeBtn>
            </div>
          ) : screenMap[step]}
        </div>
      </div>
    </div>
  );
}
