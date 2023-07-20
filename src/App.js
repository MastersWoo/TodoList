import React from "react";
import InsertForm from "./components/InsertForm";

function App() {
  return (
    <div className="App">
      <InsertForm onInsert={console.log} />
    </div>
  );
}

export default App;
