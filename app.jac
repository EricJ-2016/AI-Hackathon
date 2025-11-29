
#  AFYA-MIND: Minimal MVP Mental Health Screening System
#  Jac App (Frontend + Backend + ByLLM AI Assistant)

# BACKEND MODELS


node User {
    has username: str;
    has screenings: list = [];
}

node Screening {
    has tool: str;
    has answers: list;
    has score: int;
    has result: str;
}


# BACKEND: SCORING LOGIC (Simplified for MVP)

walker compute_PHQ9 {
    has answers: list;

    can compute with `root entry {
        score = 0;
        for a in self.answers {
            score += int(a);
        }

        result = (
            "Minimal" if score <= 4 else
            "Mild" if score <= 9 else
            "Moderate" if score <= 14 else
            "Moderately Severe" if score <= 19 else
            "Severe"
        );

        new_s = here ++> Screening(
            tool="PHQ-9",
            answers=self.answers,
            score=score,
            result=result
        );

        report {"score": score, "result": result, "screening": new_s};
    }
}

walker compute_GAD7 {
    has answers: list;

    can compute with `root entry {
        score = sum([int(x) for x in self.answers]);

        result = (
            "Minimal Anxiety" if score <= 4 else
            "Mild Anxiety" if score <= 9 else
            "Moderate Anxiety" if score <= 14 else
            "Severe Anxiety"
        );

        new_s = here ++> Screening(
            tool="GAD-7",
            answers=self.answers,
            score=score,
            result=result
        );

        report {"score": score, "result": result, "screening": new_s};
    }
}

walker compute_ARM16 {
    has answers: list;

    can compute with `root entry {
        score = sum([int(x) for x in self.answers]);

        result = (
            "Very Low Resilience" if score <= 32 else
            "Low Resilience" if score <= 48 else
            "Moderate" if score <= 64 else
            "High Resilience"
        );

        new_s = here ++> Screening(
            tool="ARM-16",
            answers=self.answers,
            score=score,
            result=result
        );

        report {"score": score, "result": result, "screening": new_s};
    }
}

walker compute_WERCAP {
    has answers: list;

    can compute with `root entry {
        score = sum([int(x) for x in self.answers]);

        severity = (
            "Low Psychosis Risk" if score <= 20 else
            "Moderate Risk" if score <= 40 else
            "High Risk"
        );

        new_s = here ++> Screening(
            tool="WERCAP",
            answers=self.answers,
            score=score,
            result=severity
        );

        report {"score": score, "result": severity, "screening": new_s};
    }
}


# AI FEEDBACK USING BYLLM


walker ai_feedback {
    has text: str;

    can respond with `root entry {
        response = byllm(
            prompt=f"""
            You are MentaBot — a supportive AI mental health assistant.
            Respond with empathy. Avoid medical claims.

            User Screening Summary:
            {self.text}

            Provide:
            - A 3–4 sentence supportive message
            - A simple coping strategy
            - One Swahili encouragement line
            """
        );

        report response;
    }
}

# FRONTEND


cl import from react { useState, useEffect }

cl {

# REUSABLE COMPONENT: QUESTION INPUT

    def Question(label: str, value: str, onChange: any) -> any {
        return <div style={{"marginBottom": "12px"}}>
            <label>{label}</label><br />
            <input
                type="number"
                min="0"
                max="3"
                value={value}
                onChange={lambda e: any -> None {
                    onChange(e.target.value);
                }}
            />
        </div>;
    }

# MAIN APP


    def app() -> any {
        let [screen, setScreen] = useState("menu");
        let [answers, setAnswers] = useState(["0","0","0"]);
        let [result, setResult] = useState(null);
        let [aiText, setAiText] = useState("");


# Handle Screening Submission

        async def submit(tool: str) -> None {
            if tool == "PHQ9" {
                r = root spawn compute_PHQ9(answers=answers);
            } elif tool == "GAD7" {
                r = root spawn compute_GAD7(answers=answers);
            } elif tool == "ARM16" {
                r = root spawn compute_ARM16(answers=answers);
            } else {
                r = root spawn compute_WERCAP(answers=answers);
            }

            summary = f"{tool} Score: {r.score}, Result: {r.result}"
            setResult(summary)

            ai_r = root spawn ai_feedback(text=summary);
            setAiText(ai_r);

            setScreen("results");
        }


# SCREEN: SWAHILI CHATBOT STYLE RESULTS

        def ResultScreen() -> any {
            return <div>
                <h2>Results</h2>
                <p>{result}</p>
                <h3>AI Feedback (MentaBot)</h3>
                <p>{aiText}</p>
                <button onClick={lambda -> None { setScreen("menu") }}>
                    Back to Menu
                </button>
            </div>;
        }


# SCREEN: MENU


        def Menu() -> any {
            return <div>
                <h1>AFYA-MIND</h1>
                <p>Mental Health Screening MVP</p>

                <button onClick={lambda -> None { 
                    setScreen("screening");
                }}>
                    Start Screening
                </button>
            </div>;
        }


# SCREEN: UNIVERSAL SCREENING FORM


        def ScreeningForm() -> any {
            return <div>
                <h2>Complete Screening</h2>

                {answers.map(lambda (a, i): any -> any {
                    return <Question
                        label={f"Q{i+1} (0–3):"}
                        value={answers[i]}
                        onChange={lambda val: any -> None {
                            newA = answers.slice();
                            newA[i] = val;
                            setAnswers(newA);
                        }}
                    />;
                })}

                <button onClick={lambda -> None { submit("PHQ9") }}>
                    Submit PHQ-9
                </button>
                <button onClick={lambda -> None { submit("GAD7") }}>
                    Submit GAD-7
                </button>
                <button onClick={lambda -> None { submit("ARM16") }}>
                    Submit ARM-16
                </button>
                <button onClick={lambda -> None { submit("WERCAP") }}>
                    Submit WERCAP
                </button>
            </div>;
        }


# SCREEN SWITCHER


        if screen == "menu" {
            return <Menu />;
        } elif screen == "screening" {
            return <ScreeningForm />;
        } else {
            return <ResultScreen />;
        }
    }
}
